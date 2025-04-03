CREATE TABLE meta.data_checkpoints (
    table_name TEXT PRIMARY KEY,
    max_value TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT now()
);