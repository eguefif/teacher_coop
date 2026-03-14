# server

## Database

### Constraint naming

All database constraints must be explicitly named in migrations. This makes constraint errors identifiable at the application level.

Example from `priv/migrations/20260221111727-CreateUserTable.sql`:

```sql
email text NOT NULL CONSTRAINT unique_email UNIQUE
```

### Handling constraint violations

When inserting or updating rows, `pog` may return a `ConstraintViolated` error. Use `pog.extract_constraint_name` to get the constraint name and match against it to return the appropriate response.

```gleam
case result {
  Error(pog.ConstraintViolated(message, constraint, _detail)) ->
    case pog.extract_constraint_name(constraint) {
      "unique_email" -> // handle duplicate email
      _ -> // handle unexpected constraint
    }
  Error(_) -> // handle other db errors
  Ok(row) -> // success
}
```

### Constraint inventory

> TODO: document all named constraints and their meaning here as they are added.
