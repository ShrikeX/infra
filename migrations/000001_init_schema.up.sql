CREATE SCHEMA IF NOT EXISTS shrikex;

-- Projects Table
CREATE TABLE shrikex.projects (
    id UUID PRIMARY KEY,
    name VARCHAR(512) NOT NULL,
    base_domain VARCHAR(2048) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_projects_name_base_domain UNIQUE (name, base_domain)
);

-- method type
CREATE TYPE shrikex.METHOD_TYPE AS ENUM('GET', 'POST', 'PUT', 'DELETE', 'PATCH');

-- Collections
CREATE TABLE shrikex.collections (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL,
    parent_collection_id UUID DEFAULT NULL,
    name VARCHAR(2048) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_project_id
        FOREIGN KEY (project_id)
        REFERENCES shrikex.projects(id),
    CONSTRAINT fk_parent_collection_id
        FOREIGN KEY (parent_collection_id)
        REFERENCES shrikex.collections(id)
);


-- Endpoints
CREATE TABLE shrikex.endpoints (
    id UUID PRIMARY KEY,
    project_id UUID NOT NULL,
    collection_id UUID NOT NULL,

    path VARCHAR(2048) NOT NULL,
    method shrikex.METHOD_TYPE NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_project
        FOREIGN KEY(project_id)
        REFERENCES shrikex.projects(id),

    CONSTRAINT fk_collection
        FOREIGN KEY(collection_id)
        REFERENCES shrikex.collections(id),

    CONSTRAINT uq_endpoint
        UNIQUE (project_id, collection_id, path, method)
);

-- Index for fast proxy lookup
CREATE INDEX idx_endpoints_lookup
ON shrikex.endpoints (project_id, path, method);

CREATE INDEX idx_collections_project_id
ON shrikex.collections(project_id);

CREATE INDEX idx_collections_parent_id
ON shrikex.collections(parent_collection_id);

CREATE INDEX idx_endpoints_collection_id
ON shrikex.endpoints(collection_id);
