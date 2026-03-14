# Stack Profile Schema

Three JSON files produced by enterprise-discover, stored in `.claude/enterprise-state/`.

---

## 1. `stack-profile.json` — Structure, Commands, Conventions

> The JSON below shows an **example** for a Node.js/Express monorepo. Your project's profile will have different values based on what `/enterprise-discover` detects.

```json
{
  "version": "1.0",
  "profiled_at": "2026-03-14T10:00:00Z",
  "profiled_commit": "abc1234",
  "stack": {
    "language": "javascript",
    "framework": "express",
    "framework_version": "4.18",
    "runtime": "node",
    "runtime_version": "20",
    "package_manager": "npm",
    "monorepo_tool": "turborepo",
    "workspace_packages": [
      { "name": "api", "path": "apps/api", "purpose": "Express backend" },
      { "name": "admin", "path": "apps/admin", "purpose": "React + Vite frontend" }
    ]
  },
  "structure": {
    "project_root": "/Users/user/project",
    "source_dirs": {
      "backend": "apps/api/src",
      "frontend": "apps/admin/src"
    },
    "test_dirs": {
      "backend": "apps/api/src/__tests__",
      "frontend": "apps/admin/src/__tests__"
    },
    "migration_dir": "apps/api/database/migrations",
    "config_dir": ".",
    "scripts_dir": "scripts",
    "docs_dir": "docs",
    "entry_points": {
      "backend": "apps/api/src/index.js",
      "frontend": "apps/admin/src/main.jsx"
    }
  },
  "commands": {
    "test_all": "cd apps/api && npx jest --no-coverage --forceExit",
    "test_single": "cd apps/api && npx jest --testPathPattern=\"{pattern}\" --no-coverage",
    "test_no_coverage": "cd apps/api && npx jest --no-coverage --forceExit",
    "test_framework": "jest",
    "test_framework_version_cmd": "npx jest --version",
    "build_frontend": "cd apps/admin && npx vite build",
    "lint": "",
    "dev_server": "npm run dev",
    "migration_runner": "psql"
  },
  "database": {
    "type": "postgresql",
    "orm": "raw pg via pool.query()",
    "migration_system": "raw SQL files",
    "migration_naming": "sequential numbers: NNN_name.sql"
  },
  "auth": {
    "middleware_name": "authenticateStaff",
    "middleware_path": "apps/api/src/middleware/auth.js",
    "user_object": "req.user",
    "user_fields": ["id", "email", "first_name", "last_name", "tenant_id"],
    "pattern": "JWT via middleware"
  },
  "multi_tenancy": {
    "enabled": true,
    "field": "tenant_id",
    "enforcement": "column filter",
    "exceptions": ["customers"]
  },
  "routes": {
    "style": "Express router with explicit mounting",
    "mount_file": "apps/api/src/index.js",
    "prefix_convention": "/api/resource",
    "public_before_auth": true
  },
  "conventions": {
    "file_naming": "camelCase.js",
    "variable_naming": "camelCase",
    "db_column_naming": "snake_case",
    "import_style": "CommonJS require",
    "error_pattern": "try/catch with res.status().json()",
    "logger": "console",
    "service_pattern": "function exports from service files",
    "file_extensions": [".js", ".jsx"],
    "file_size_soft_limit": 400,
    "file_size_hard_limit": 800
  },
  "git": {
    "default_branch": "dev",
    "protected_branches": ["master"],
    "commit_style": "conventional commits",
    "remote": "github"
  }
}
```

### Required Fields

All top-level keys are required. Within each section:

| Section | Required Fields |
|---------|----------------|
| `stack` | `language`, `framework`, `package_manager` |
| `structure` | `project_root`, `source_dirs.backend` |
| `commands` | `test_all`, `test_single`, `test_framework` |
| `database` | `type` |
| `auth` | `middleware_name` (empty string if none) |
| `multi_tenancy` | `enabled`, `field` |
| `conventions` | `file_extensions` |
| `git` | `default_branch` |

### Optional Fields

- `structure.source_dirs.frontend` — empty string if no frontend
- `commands.build_frontend` — empty string if no build step
- `commands.lint` — empty string if no linter
- `auth.user_fields` — empty array if unknown
- `multi_tenancy.exceptions` — empty array if no exceptions
- `workspace_packages` — empty array if not a monorepo

---

## 2. `stack-traps.json` — Type/Schema/Convention Traps

Traps are things that will break code if the developer doesn't know about them. These are discovered by analyzing schema, types, and conventions.

```json
{
  "version": "1.0",
  "profiled_at": "2026-03-14T10:00:00Z",
  "traps": [
    {
      "id": "trap-001",
      "category": "type_mismatch",
      "severity": "high",
      "title": "Supplier ID type mismatch",
      "description": "suppliers.id is UUID but products.supplier_id is integer",
      "affected_tables": ["suppliers", "products"],
      "workaround": "Cast both to text for joins: WHERE suppliers.id::text = products.supplier_id::text",
      "fixable": false,
      "fix_notes": "Requires migration to unify types"
    },
    {
      "id": "trap-002",
      "category": "schema_convention",
      "severity": "medium",
      "title": "customers table has no tenant_id",
      "description": "The customers table is the tenant itself — it has no tenant_id column",
      "affected_tables": ["customers"],
      "workaround": "Do not add tenant_id WHERE clause when querying customers directly",
      "fixable": false,
      "fix_notes": "By design — customers ARE tenants"
    }
  ]
}
```

### Trap Categories

| Category | Description |
|----------|-------------|
| `type_mismatch` | Column type inconsistencies across tables |
| `schema_convention` | Schema patterns that break assumptions |
| `naming_inconsistency` | Inconsistent naming across the codebase |
| `import_trap` | Import patterns that don't work as expected |
| `env_trap` | Environment variable gotchas |
| `timing_trap` | Race conditions, timezone issues |

### Severity Levels

| Severity | Meaning |
|----------|---------|
| `high` | Will cause data corruption or security issues if missed |
| `medium` | Will cause bugs or test failures if missed |
| `low` | Style/consistency issue, no functional impact |

---

## 3. `stack-best-practices.json` — Framework-Specific Guidance

Best practices sourced from web research for the detected stack.

```json
{
  "version": "1.0",
  "profiled_at": "2026-03-14T10:00:00Z",
  "stack_key": "express-4-postgresql-jest",
  "practices": [
    {
      "category": "testing",
      "practice": "Use supertest for HTTP endpoint testing",
      "rationale": "Tests the full middleware chain including auth and validation",
      "source": "Express.js best practices 2026"
    },
    {
      "category": "security",
      "practice": "Use helmet middleware for security headers",
      "rationale": "Prevents common web vulnerabilities with minimal config",
      "source": "OWASP Express security guide"
    },
    {
      "category": "database",
      "practice": "Use connection pooling with pg-pool",
      "rationale": "Prevents connection exhaustion under load",
      "source": "node-postgres documentation"
    }
  ]
}
```

### Practice Categories

`testing`, `security`, `database`, `error_handling`, `performance`, `deployment`, `logging`, `auth`

---

## Variable Mapping

Skills reference stack-profile.json values using `$VARIABLE` names:

| Variable | JSON Path | Fallback |
|----------|-----------|----------|
| `$PROJECT_ROOT` | `structure.project_root` | `git rev-parse --show-toplevel` |
| `$SOURCE_DIR` | `structure.source_dirs.backend` | `src` |
| `$FRONTEND_DIR` | `structure.source_dirs.frontend` | _(empty)_ |
| `$TEST_DIR` | `structure.test_dirs.backend` | `tests` |
| `$TEST_CMD` | `commands.test_all` | `npx jest` |
| `$TEST_SINGLE_CMD` | `commands.test_single` | `npx jest --testPathPattern` |
| `$TEST_FRAMEWORK` | `commands.test_framework` | `jest` |
| `$BUILD_CMD` | `commands.build_frontend` | _(empty)_ |
| `$LINT_CMD` | `commands.lint` | _(empty)_ |
| `$AUTH_MIDDLEWARE` | `auth.middleware_name` | _(empty)_ |
| `$TENANT_FIELD` | `multi_tenancy.field` | `none` |
| `$TENANT_ENABLED` | `multi_tenancy.enabled` | `false` |
| `$DB_TYPE` | `database.type` | `postgresql` |
| `$MIGRATION_DIR` | `structure.migration_dir` | _(empty)_ |
| `$MIGRATION_RUNNER` | `commands.migration_runner` | _(empty)_ |
| `$BRANCH_MAIN` | `git.default_branch` | `main` |
| `$BRANCH_PROTECTED` | `git.protected_branches` | `["main"]` |
| `$FILE_EXTENSIONS` | `conventions.file_extensions` | `[".js", ".ts"]` |
