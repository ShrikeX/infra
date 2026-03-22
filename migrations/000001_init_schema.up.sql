-- Projects Table
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    name VARCHAR(512) NOT NULL,
    base_domain VARCHAR(2048) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_projects_name_base_domain UNIQUE (name, base_domain)
);

-- method type
CREATE TYPE METHOD_TYPE AS ENUM('GET', 'POST', 'PUT', 'DELETE', 'PATCH');

-- Collections
CREATE TABLE collections (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL,
    parent_collection_id UUID DEFAULT NULL,
    name VARCHAR(2048) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_project_id
        FOREIGN KEY (project_id)
        REFERENCES projects(id),
    CONSTRAINT fk_parent_collection_id
        FOREIGN KEY (parent_collection_id)
        REFERENCES collections(id)
);


-- Endpoints
CREATE TABLE endpoints (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL,
    collection_id UUID NOT NULL,

    path VARCHAR(2048) NOT NULL,
    method METHOD_TYPE NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_project
        FOREIGN KEY(project_id)
        REFERENCES projects(id),

    CONSTRAINT fk_collection
        FOREIGN KEY(collection_id)
        REFERENCES collections(id)
);

-- Index for fast proxy lookup
CREATE INDEX idx_endpoints_lookup
ON endpoints (project_id, path, method);
