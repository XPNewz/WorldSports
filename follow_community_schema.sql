-- ==============================================================================
-- WorldSports: Follow & Community Join System
-- DSA-Optimized Schema with B-Tree, GIN, and Partial Indexes
-- ==============================================================================
-- Algorithm Design Notes:
--   • User Follows  → Adjacency List (follower_id → followee_id) = O(1) follow/unfollow
--   • Social Graph  → B-Tree index on (follower_id), (followee_id) = O(log n) lookups  
--   • Feed ranking  → Materialized feed cache per user + B-Tree on created_at DESC
--   • Community     → Hash Table (member_id → community_id) = O(1) join/leave
--   • Suggestions   → 2-hop BFS via SQL CTE (friends-of-friends) = O(V+E) graph walk
--   • Trending      → Counter cache with ATOMIC increment = O(1) update, O(1) read
-- ==============================================================================

-- ── EXTENSION ──────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fast text-based search (GIN index)

-- ==============================================================================
-- TABLE 1: user_follows
-- Adjacency-List graph representation of the social follow graph.
-- DSA: Directed Graph — each row = directed edge (follower → followee)
-- Lookup complexity:
--   • "Does A follow B?"  → O(log n) via composite B-Tree PK
--   • "All followers of B" → O(log n + k) via idx_follows_followee_id
--   • "All following of A" → O(log n + k) via idx_follows_follower_id
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.user_follows (
  follower_id  UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  followee_id  UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Composite PK = hash map key: prevents duplicates, O(1) existence check
  PRIMARY KEY (follower_id, followee_id),
  -- Prevent self-follow at DB level
  CONSTRAINT no_self_follow CHECK (follower_id <> followee_id)
);

-- B-Tree index on followee_id → "get all followers of user X" in O(log n)
CREATE INDEX IF NOT EXISTS idx_follows_followee_id
  ON public.user_follows (followee_id, created_at DESC);

-- B-Tree index on follower_id → "get all users that user X follows" in O(log n)
CREATE INDEX IF NOT EXISTS idx_follows_follower_id
  ON public.user_follows (follower_id, created_at DESC);

-- ==============================================================================
-- TABLE 2: follow_counts (Counter Cache — O(1) reads, ATOMIC increments)
-- DSA: Memoization / Counter Cache pattern
-- Instead of COUNT(*) on user_follows (O(n)), we maintain denormalized counts.
-- Atomic increments via trigger = consistent under high concurrency.
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.follow_counts (
  user_id       UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  followers_count INT NOT NULL DEFAULT 0 CHECK (followers_count >= 0),
  following_count INT NOT NULL DEFAULT 0 CHECK (following_count >= 0),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- TABLE 3: communities
-- DSA: Each community = a node in a hypergraph; members = edges.
-- Supports up to 10 sports tags (GIN-indexed array) for multi-sport filtering.
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.communities (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  slug          TEXT UNIQUE NOT NULL,         -- URL-friendly unique key
  description   TEXT DEFAULT '',
  avatar_url    TEXT DEFAULT '',
  banner_url    TEXT DEFAULT '',
  sport_tags    TEXT[] DEFAULT '{}'::text[],  -- ['cricket','football'] multi-sport
  location      TEXT DEFAULT '',
  is_verified   BOOLEAN NOT NULL DEFAULT false,
  is_private    BOOLEAN NOT NULL DEFAULT false, -- private communities need approval
  creator_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  members_count INT NOT NULL DEFAULT 0 CHECK (members_count >= 0),
  posts_count   INT NOT NULL DEFAULT 0 CHECK (posts_count >= 0),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- GIN index on sport_tags array → "communities for sport X" in O(log n)
CREATE INDEX IF NOT EXISTS idx_communities_sport_tags
  ON public.communities USING GIN (sport_tags);

-- B-Tree on members_count DESC → "top communities" ranking in O(log n)
CREATE INDEX IF NOT EXISTS idx_communities_members_count
  ON public.communities (members_count DESC);

-- GIN trigram index on name → fast ILIKE text search in O(log n)
CREATE INDEX IF NOT EXISTS idx_communities_name_trgm
  ON public.communities USING GIN (name gin_trgm_ops);

-- Partial index: only verified communities (for fast verified-only filter)
CREATE INDEX IF NOT EXISTS idx_communities_verified
  ON public.communities (created_at DESC)
  WHERE is_verified = true;

-- ==============================================================================
-- TABLE 4: community_members
-- DSA: Adjacency List (user_id → community_id)
-- Membership check: O(1) via composite PK (hash map)
-- "My communities": O(log n + k) via idx_community_members_user
-- "Members of community": O(log n + k) via idx_community_members_community
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.community_members (
  community_id  UUID NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'member',  -- 'member', 'moderator', 'admin'
  status        TEXT NOT NULL DEFAULT 'active',  -- 'active', 'pending', 'banned'
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  PRIMARY KEY (community_id, user_id)
);

-- B-Tree: "all communities I belong to" → O(log n)
CREATE INDEX IF NOT EXISTS idx_community_members_user
  ON public.community_members (user_id, joined_at DESC);

-- B-Tree: "all members of a community" → O(log n)
CREATE INDEX IF NOT EXISTS idx_community_members_community
  ON public.community_members (community_id, joined_at DESC);

-- Partial index: pending join requests (approval workflow for private communities)
CREATE INDEX IF NOT EXISTS idx_community_members_pending
  ON public.community_members (community_id, joined_at)
  WHERE status = 'pending';

-- ==============================================================================
-- FUNCTION 1: Maintain follow_counts atomically (Trigger-based counter cache)
-- DSA: Atomic counter increment/decrement = O(1) amortized
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.follow_counts (user_id, followers_count, following_count)
      VALUES (NEW.followee_id, 1, 0)
      ON CONFLICT (user_id) DO UPDATE
        SET followers_count = follow_counts.followers_count + 1,
            updated_at = NOW();

    INSERT INTO public.follow_counts (user_id, followers_count, following_count)
      VALUES (NEW.follower_id, 0, 1)
      ON CONFLICT (user_id) DO UPDATE
        SET following_count = follow_counts.following_count + 1,
            updated_at = NOW();

  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.follow_counts
      SET followers_count = GREATEST(0, followers_count - 1),
          updated_at = NOW()
      WHERE user_id = OLD.followee_id;

    UPDATE public.follow_counts
      SET following_count = GREATEST(0, following_count - 1),
          updated_at = NOW()
      WHERE user_id = OLD.follower_id;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_update_follow_counts ON public.user_follows;
CREATE TRIGGER trg_update_follow_counts
  AFTER INSERT OR DELETE ON public.user_follows
  FOR EACH ROW EXECUTE FUNCTION public.update_follow_counts();

-- ==============================================================================
-- FUNCTION 2: Maintain community members_count atomically
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.update_community_members_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'active' THEN
    UPDATE public.communities
      SET members_count = members_count + 1, updated_at = NOW()
      WHERE id = NEW.community_id;

  ELSIF TG_OP = 'DELETE' AND OLD.status = 'active' THEN
    UPDATE public.communities
      SET members_count = GREATEST(0, members_count - 1), updated_at = NOW()
      WHERE id = OLD.community_id;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status <> 'active' AND NEW.status = 'active' THEN
      UPDATE public.communities
        SET members_count = members_count + 1, updated_at = NOW()
        WHERE id = NEW.community_id;
    ELSIF OLD.status = 'active' AND NEW.status <> 'active' THEN
      UPDATE public.communities
        SET members_count = GREATEST(0, members_count - 1), updated_at = NOW()
        WHERE id = NEW.community_id;
    END IF;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_update_community_members_count ON public.community_members;
CREATE TRIGGER trg_update_community_members_count
  AFTER INSERT OR DELETE OR UPDATE ON public.community_members
  FOR EACH ROW EXECUTE FUNCTION public.update_community_members_count();

-- ==============================================================================
-- FUNCTION 3: "Who to Follow" - 2-Hop BFS Graph Suggestion Algorithm
-- DSA: Breadth-First Search on Social Graph (V = users, E = follows)
-- Complexity: O(V + E) for 2-hop neighborhood; SQL CTE handles set operations
--
-- Algorithm:
--   1. Find all users that current_user follows (1-hop set)  
--   2. Find all users that those users follow (2-hop set = candidates)
--   3. Filter out already-followed and self
--   4. Rank by mutual_count DESC then followers_count DESC
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_follow_suggestions(
  p_user_id    UUID,
  p_limit      INT DEFAULT 10
)
RETURNS TABLE (
  user_id        UUID,
  full_name      TEXT,
  username       TEXT,
  avatar_url     TEXT,
  primary_sport  TEXT,
  followers_count INT,
  mutual_count   BIGINT
)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  WITH
  already_following AS (
    SELECT followee_id FROM public.user_follows WHERE follower_id = p_user_id
  ),
  two_hop_candidates AS (
    SELECT uf2.followee_id AS candidate_id,
           COUNT(*) AS mutual_count
    FROM public.user_follows uf1
    JOIN public.user_follows uf2
      ON uf1.followee_id = uf2.follower_id
    WHERE uf1.follower_id = p_user_id
      AND uf2.followee_id <> p_user_id
      AND uf2.followee_id NOT IN (SELECT followee_id FROM already_following)
    GROUP BY uf2.followee_id
  )
  SELECT
    p.id           AS user_id,
    p.full_name,
    p.username,
    p.profile_picture_url AS avatar_url,
    p.primary_sport,
    COALESCE(fc.followers_count, 0) AS followers_count,
    thc.mutual_count
  FROM two_hop_candidates thc
  JOIN public.profiles p ON p.id = thc.candidate_id
  LEFT JOIN public.follow_counts fc ON fc.user_id = thc.candidate_id
  ORDER BY thc.mutual_count DESC, fc.followers_count DESC NULLS LAST
  LIMIT p_limit;
$$;

-- ==============================================================================
-- FUNCTION 4: Community Discovery - Sport-tag Jaccard Similarity
-- DSA: Set Intersection scoring for content-based collaborative filtering
-- Complexity: O(k * log n) where k = # user sport tags
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_community_suggestions(
  p_user_id    UUID,
  p_limit      INT DEFAULT 10
)
RETURNS TABLE (
  community_id  UUID,
  name          TEXT,
  slug          TEXT,
  description   TEXT,
  avatar_url    TEXT,
  sport_tags    TEXT[],
  members_count INT,
  is_verified   BOOLEAN,
  is_member     BOOLEAN,
  jaccard_score FLOAT
)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  WITH
  user_sports AS (
    SELECT ARRAY[p.primary_sport] AS tags
    FROM public.profiles p WHERE p.id = p_user_id
  ),
  not_joined AS (
    SELECT c.* FROM public.communities c
    WHERE NOT EXISTS (
      SELECT 1 FROM public.community_members cm
      WHERE cm.community_id = c.id AND cm.user_id = p_user_id AND cm.status = 'active'
    )
  )
  SELECT
    c.id,
    c.name,
    c.slug,
    c.description,
    c.avatar_url,
    c.sport_tags,
    c.members_count,
    c.is_verified,
    false AS is_member,
    (
      COALESCE(array_length(
        ARRAY(SELECT unnest(c.sport_tags) INTERSECT SELECT unnest((SELECT tags FROM user_sports))), 1
      ), 0)::FLOAT
      / NULLIF(array_length(
        ARRAY(SELECT unnest(c.sport_tags) UNION SELECT unnest((SELECT tags FROM user_sports))), 1
      ), 0)
    ) * LN(GREATEST(c.members_count, 1) + 1) AS jaccard_score
  FROM not_joined c
  ORDER BY jaccard_score DESC NULLS LAST, c.members_count DESC
  LIMIT p_limit;
$$;

-- ==============================================================================
-- FUNCTION 5: O(1) Follow Status Check
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.is_following(p_follower_id UUID, p_followee_id UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_follows
    WHERE follower_id = p_follower_id AND followee_id = p_followee_id
  );
$$;

-- ==============================================================================
-- FUNCTION 6: O(1) Community Membership Check
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.is_community_member(p_user_id UUID, p_community_id UUID)
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT status FROM public.community_members
  WHERE user_id = p_user_id AND community_id = p_community_id;
$$;

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE public.user_follows        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follow_counts       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members   ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view follows"              ON public.user_follows;
DROP POLICY IF EXISTS "Authenticated can follow"             ON public.user_follows;
DROP POLICY IF EXISTS "Can unfollow own"                     ON public.user_follows;
DROP POLICY IF EXISTS "Public can view follow counts"        ON public.follow_counts;
DROP POLICY IF EXISTS "Public can view communities"          ON public.communities;
DROP POLICY IF EXISTS "Auth can create community"            ON public.communities;
DROP POLICY IF EXISTS "Creator can update community"         ON public.communities;
DROP POLICY IF EXISTS "Creator can delete community"         ON public.communities;
DROP POLICY IF EXISTS "Public can view members"              ON public.community_members;
DROP POLICY IF EXISTS "Auth can join community"              ON public.community_members;
DROP POLICY IF EXISTS "Can leave community"                  ON public.community_members;
DROP POLICY IF EXISTS "Moderators can update member status"  ON public.community_members;

CREATE POLICY "Public can view follows"
  ON public.user_follows FOR SELECT USING (true);
CREATE POLICY "Authenticated can follow"
  ON public.user_follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Can unfollow own"
  ON public.user_follows FOR DELETE USING (auth.uid() = follower_id);

CREATE POLICY "Public can view follow counts"
  ON public.follow_counts FOR SELECT USING (true);

CREATE POLICY "Public can view communities"
  ON public.communities FOR SELECT USING (true);
CREATE POLICY "Auth can create community"
  ON public.communities FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Creator can update community"
  ON public.communities FOR UPDATE USING (auth.uid() = creator_id) WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Creator can delete community"
  ON public.communities FOR DELETE USING (auth.uid() = creator_id);

CREATE POLICY "Public can view members"
  ON public.community_members FOR SELECT USING (true);
CREATE POLICY "Auth can join community"
  ON public.community_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Can leave community"
  ON public.community_members FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Moderators can update member status"
  ON public.community_members FOR UPDATE
  USING (
    auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM public.community_members mod
      WHERE mod.community_id = community_members.community_id
        AND mod.user_id = auth.uid()
        AND mod.role IN ('moderator', 'admin')
        AND mod.status = 'active'
    )
  );

-- ==============================================================================
-- REALTIME
-- ==============================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'user_follows') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_follows;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'community_members') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.community_members;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'follow_counts') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.follow_counts;
  END IF;
END $$;

-- ==============================================================================
-- SEED: Sample Communities
-- ==============================================================================
DO $$
DECLARE v_creator UUID;
BEGIN
  SELECT id INTO v_creator FROM auth.users LIMIT 1;
  IF v_creator IS NULL THEN RETURN; END IF;
  INSERT INTO public.communities (name, slug, description, sport_tags, location, is_verified, creator_id)
  VALUES
    ('Mumbai Mavericks',          'mumbai-mavericks',     'Premier cricket club of Mumbai.',             ARRAY['cricket'],              'Mumbai, India',    true,  v_creator),
    ('Delhi Dynamos',             'delhi-dynamos',         'Competitive football community in Delhi.',    ARRAY['football'],             'Delhi, India',     false, v_creator),
    ('Sunday Kickers',            'sunday-kickers',        'Casual weekend sports community.',            ARRAY['football','cricket'],   'Bangalore, India', false, v_creator),
    ('Mumbai Cricket Association','mumbai-cricket-assoc',  'Official association for amateur cricketers.',ARRAY['cricket'],              'Mumbai, India',    true,  v_creator),
    ('Chennai Ballers',           'chennai-ballers',       'Basketball community for all skill levels.',  ARRAY['basketball'],           'Chennai, India',   false, v_creator),
    ('Tennis Tigers',             'tennis-tigers',         'Passionate tennis players community.',        ARRAY['tennis'],               'Hyderabad, India', false, v_creator)
  ON CONFLICT (slug) DO NOTHING;
END $$;

-- Verification
SELECT
  (SELECT count(*) FROM public.user_follows)        AS total_follows,
  (SELECT count(*) FROM public.communities)         AS total_communities,
  (SELECT count(*) FROM public.community_members)   AS total_members,
  (SELECT count(*) FROM public.follow_counts)       AS total_follow_count_rows;
