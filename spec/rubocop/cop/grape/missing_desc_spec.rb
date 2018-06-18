RSpec.describe RuboCop::Cop::Grape::MissingDesc, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'TopLevel' => false } }

  it 'does not register an offense for a class with no superclass' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo
      end
    RUBY
  end

  it 'does not register an offense for a class with a different superclass' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Foo < Bar
      end
    RUBY
  end

  context 'for a Grape::API subclass' do
    it 'registers an offense for a class that has no desc' do
      expect_offense(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
        end
      RUBY
    end

    it 'registers an offense for a class that has a desc with no argument' do
      expect_offense(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
          desc
          ^^^^ `desc` must be given a non-empty string.
        end
      RUBY
    end

    it 'registers an offense for a class that has an empty desc string' do
      expect_offense(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
          desc ''
          ^^^^^^^ `desc` must be given a non-empty string.
        end
      RUBY
    end

    it 'does not register an offense for a class that has a desc' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
          desc 'Description'
        end
      RUBY
    end

    it 'does not register an offense for a class that has a desc and other stuff' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
          desc 'Description'

          post do
          end
        end
      RUBY
    end

    it 'does not register an offense for a class that has a desc with block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
          desc 'Description' do
            detail 'More details'
          end
        end
      RUBY
    end

    it 'registers an offense when inside a bunch of nested methods' do
      expect_offense(<<-RUBY.strip_indent)
        class Endpoint < Grape::API
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
          namespace :my_resource do
            route_param :id do
              route_param :other_id do
                post do
                end
              end
            end
          end
        end
      RUBY
    end
  end

  context 'for resource classes' do
    context 'when desc is required' do
      let(:cop_config) { super().merge('RequiredForResources' => true) }

      it 'registers an offense when desc is missing' do
        expect_offense(<<-RUBY.strip_indent)
          class Resource < Grape::API
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
            mount Foo
            mount Bar
          end
        RUBY
      end

      it 'registers an offense when inside a resource block' do
        expect_offense(<<-RUBY.strip_indent)
          class Resource < Grape::API
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
            resource :my_resource do
              mount Foo
              mount Bar
            end
          end
        RUBY
      end

      it 'does not register an offense when desc is present' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Resource < Grape::API
            desc 'Resource'

            mount Foo
            mount Bar
          end
        RUBY
      end

      it 'does not register an offense when inside a resource block' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Resource < Grape::API
            desc 'Resource'

            resource :my_resource do
              mount Foo
              mount Bar
            end
          end
        RUBY
      end
    end

    context 'when desc is not required' do
      let(:cop_config) { super().merge('RequiredForResources' => false) }

      it 'registers an offense when the class has requests' do
        expect_offense(<<-RUBY.strip_indent)
          class Resource < Grape::API
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
            mount Foo
            mount Bar

            post do
            end
          end
        RUBY
      end

      it 'does not register an offense when desc is missing' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Resource < Grape::API
            mount Foo
            mount Bar
          end
        RUBY
      end

      it 'does not register an offense when desc is present' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Resource < Grape::API
            desc 'Resource'

            mount Foo
            mount Bar
          end
        RUBY
      end

      it 'does not register an offense when inside a resource block' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Resource < Grape::API
            resource :my_resource do
              mount Foo
              mount Bar
            end
          end
        RUBY
      end

      it 'does not register an offense when inside a resource block' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Resource < Grape::API
            desc 'Resource'

            resource :my_resource do
              mount Foo
              mount Bar
            end
          end
        RUBY
      end
    end
  end

  context 'top-level' do
    context 'when true' do
      let(:cop_config) { { 'TopLevel' => true } }

      it 'registers an offense if there is no description' do
        expect_offense(<<-RUBY.strip_indent)
          class MyEndpoint < Grape::API
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
          end
        RUBY
      end

      it 'registers an offense if the description is not top level' do
        expect_offense(<<-RUBY.strip_indent)
          class MyEndpoint < Grape::API
            route_param :id do
              desc 'Description'
              ^^^^^^^^^^^^^^^^^^ `desc` must not be placed within a block.

              post do
                # ...
              end
            end
          end
        RUBY
      end

      it 'does not register an offense if the description is top level' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class MyEndpoint < Grape::API
            desc 'Description'

            route_param :id do
              post do
                # ...
              end
            end
          end
        RUBY
      end

      it 'does not register an offense for a top level desc with a block' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Endpoint < Grape::API
            desc 'Description' do
              detail 'More details'
            end
          end
        RUBY
      end
    end

    context 'when false' do
      let(:cop_config) { { 'TopLevel' => false } }

      it 'registers an offense if there is no description' do
        expect_offense(<<-RUBY.strip_indent)
          class MyEndpoint < Grape::API
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Grape API classes must have a `desc`.
          end
        RUBY
      end

      it 'does not register an offense if the description is not top level' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class MyEndpoint < Grape::API
            route_param :id do
              desc 'Description'

              post do
                # ...
              end
            end
          end
        RUBY
      end

      it 'does not register an offense if the description is top level' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class MyEndpoint < Grape::API
            desc 'Description'

            route_param :id do
              post do
                # ...
              end
            end
          end
        RUBY
      end
    end
  end

  context 'auto-correction' do
    let(:cop_config) { { 'TopLevel' => true } }

    it 'moves a non-top level description' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class MyEndpoint < Grape::API
          namespace :my_namespace do
            route_param :id do
              desc 'Description'

              post do
              end
            end
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class MyEndpoint < Grape::API
          desc 'Description'

          namespace :my_namespace do
            route_param :id do
              post do
              end
            end
          end
        end
      RUBY
    end

    it 'moves a non-top level description with a block' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class MyEndpoint < Grape::API
          namespace :my_namespace do
            route_param :id do
              desc 'Description' do
                detail 'more details'
              end
            end
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class MyEndpoint < Grape::API
          desc 'Description' do
            detail 'more details'
          end

          namespace :my_namespace do
            route_param :id do
            end
          end
        end
      RUBY
    end

    it 'moves a non-top level description when there is other code' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        class MyEndpoint < Grape::API
          helpers do
          end

          route_param :id do
            desc 'Description' do
              detail 'more details'
            end
          end
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        class MyEndpoint < Grape::API
          desc 'Description' do
            detail 'more details'
          end

          helpers do
          end

          route_param :id do
          end
        end
      RUBY
    end
  end
end
