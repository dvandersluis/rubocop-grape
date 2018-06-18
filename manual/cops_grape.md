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

## Grape/MissingDesc

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop identifies `Grape::API` subclasses that don't have a description. Every API
method should have a description so that consumers can know how to use it.

Supports autocorrect only for descriptions in the wrong location (if TopLevel is true).

### Examples

```ruby
# bad
class MyEndpoint < Grape::API
  post do
    # ...
  end
end

# good
class MyEndpoint < Grape::API
  desc 'This is my endpoint'

  post do
    # ...
  end
end

# good
class MyEndpoint < Grape::API
  desc 'This is my endpoint' do
    detail 'more detail'
  end

  post do
    # ...
  end
end
```
#### TopLevel: true (default)

```ruby
# bad
class MyEndpoint < Grape::API
  route_param :id do
    desc 'Description'

    post do
      # ...
    end
  end
end

# good
class MyEndpoint < Grape::API
  desc 'Description'

  route_param :id do
    post do
      # ...
    end
  end
end
```
#### TopLevel: false

```ruby
# good
class MyEndpoint < Grape::API
  route_param :id do
    desc 'Description'

    post do
      # ...
    end
  end
end

# good
class MyEndpoint < Grape::API
  desc 'Description'

  route_param :id do
    post do
      # ...
    end
  end
end
```
#### RequiredForResources: true (default)

```ruby
# bad
class MyEndpoint < Grape::API
  mount Foo
  mount Bar
end

# bad
class MyResource < Grape::API
  resource :my_resource do
    mount Foo
  end
end

# good
class MyEndpoint < Grape::API
  desc 'This is my resource'

  mount Foo
  mount Bar
end

# good
class MyResource < Grape::API
  desc 'This is my resource'

  resource :my_resource do
    mount Foo
  end
end
```
#### RequiredForResources: false

```ruby
# bad
class MyEndpoint < Grape::API
  mount Foo
  mount Bar

  post do
    # ...
  end
end

# bad
class MyEndpoint < Grape::API
  resource :my_resource do
    mount Foo
    mount Bar

    post do
      # ...
    end
  end
end

# good
class MyEndpoint < Grape::API
  mount Foo
  mount Bar
end

# good
class MyResource < Grape::API
  resource :my_resource do
    mount Foo
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
RequireForResources | `true` | Boolean
TopLevel | `true` | Boolean

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
