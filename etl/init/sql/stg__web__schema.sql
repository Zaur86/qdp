-- 1. События взаимодействия (клики, скроллы, и т.п.)
CREATE TABLE stg.web__events (
    event_id UUID PRIMARY KEY,
    user_id UUID,
    session_id UUID,
    event_type TEXT,
    event_ts TIMESTAMP,
    url TEXT,
    referrer TEXT,
    user_agent TEXT,
    extra_data JSONB,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 2. Начало сессии
CREATE TABLE stg.web__session_start (
    session_id UUID PRIMARY KEY,
    user_id UUID,
    started_at TIMESTAMP,
    device TEXT,
    location TEXT,
    user_agent TEXT,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 3. Завершение сессии
CREATE TABLE stg.web__session_end (
    session_id UUID PRIMARY KEY,
    ended_at TIMESTAMP,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 4. Просмотры страниц (page views)
CREATE TABLE stg.web__page_views (
    event_id UUID PRIMARY KEY,
    session_id UUID,
    user_id UUID,
    page_url TEXT,
    viewed_at TIMESTAMP,
    referrer TEXT,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 5. Регистрации пользователей
CREATE TABLE stg.web__registrations (
    event_id UUID PRIMARY KEY,
    user_id UUID,
    session_id UUID,
    registered_at TIMESTAMP,
    registration_method TEXT,
    device TEXT,
    location TEXT,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);
