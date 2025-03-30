-- 1. События взаимодействия (клики, скроллы, и т.п.)
CREATE TABLE stg.web__events (
    event_id TEXT PRIMARY KEY,
    data JSONB,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 2. Начало сессии
CREATE TABLE stg.web__session_start (
    session_id TEXT PRIMARY KEY,
    data JSONB,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 3. Завершение сессии
CREATE TABLE stg.web__session_end (
    session_id TEXT PRIMARY KEY,
    data JSONB,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 4. Просмотры страниц (page views)
CREATE TABLE stg.web__page_views (
    event_id TEXT PRIMARY KEY,
    data JSONB,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);

-- 5. Регистрации пользователей
CREATE TABLE stg.web__registrations (
    event_id TEXT PRIMARY KEY,
    data JSONB,
    load_ts TIMESTAMP DEFAULT now(),
    record_source TEXT
);
