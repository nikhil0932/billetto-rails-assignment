# RSpec Testing Guide

This project uses **RSpec** for testing. RSpec is a Behavior-Driven Development (BDD) testing framework for Ruby.

## Setup

RSpec has been integrated with the following gems:
- **rspec-rails** - RSpec for Rails applications
- **factory_bot_rails** - Test data factories
- **shoulda-matchers** - Additional matchers for validations and associations

## Running Tests

```bash
# Run all specs
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/requests/example_spec.rb

# Run with verbose output
bundle exec rspec --format documentation

# Run with code coverage
bundle exec rspec --format documentation --coverage
```

## Spec Directory Structure

```
spec/
├── factories/          # Factory Bot factories for test data
├── requests/           # Request/integration specs
├── models/             # Model unit specs
├── controllers/        # Controller specs
├── helpers/            # Helper specs
├── jobs/               # Job specs
├── mailers/            # Mailer specs
├── system/             # Full system/feature specs
└── support/            # Shared helpers and configurations
```

## Writing Specs

### Model Spec Example

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  describe 'associations' do
    it { should have_many(:posts) }
  end

  describe '#full_name' do
    it 'returns combined first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

### Request Spec Example

```ruby
# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    it 'returns a successful response' do
      get users_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /users' do
    it 'creates a new user' do
      expect {
        post users_path, params: { user: { email: 'test@example.com' } }
      }.to change(User, :count).by(1)
    end
  end
end
```

### Factory Example

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    first_name { 'John' }
    last_name { 'Doe' }
  end
end
```

## Using Factories

```ruby
# Create a user
user = create(:user)

# Build a user (not saved to database)
user = build(:user)

# Create multiple users
users = create_list(:user, 3)
```

## GitHub Actions

The CI/CD pipeline runs RSpec on every push to `main` and on pull requests. See `.github/workflows/ci.yml` for configuration.

## Useful RSpec Commands

```bash
# Run tests in parallel (requires parallel_tests gem)
bundle exec parallel_test spec

# Run only failing tests
bundle exec rspec --only-failures

# Run tests that match a pattern
bundle exec rspec --pattern "**/requests/*_spec.rb"

# Generate a report
bundle exec rspec --format html --out coverage/rspec.html
```

## Resources

- [RSpec Documentation](https://rspec.info/)
- [Factory Bot Documentation](https://github.com/thoughtbot/factory_bot)
- [Shoulda Matchers Documentation](https://github.com/thoughtbot/shoulda-matchers)
