# Grape

## Grape/EmptyRequestPath

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop finds request blocks with an empty string as the path, which
can be left out.

### Examples

```ruby
# bad
post '' do
end

# good
post do
end

# good
post 'path' do
end
```

## Grape/StatusNoContent

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop identifies places where `status :no_content` or `status 204` should
be replaced with `body false`.

There is a bug in grape that setting `status :no_content` without a body will
cause requests to not complete in certain situations (such as in curl),
however `body false` will also set a `204 No Content` response status.

### Examples

```ruby
# bad
status :no_content

# bad
status 204

# good
body false
```
