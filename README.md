# Billetto Event Voting Application

A minimal Rails application for voting on events with Clerk authentication.

## Setup

### Prerequisites
- Ruby 3.x
- Rails 7.x
- MySQL

### Installation

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
rails db:create
rails db:migrate
```

## Running the Application

Start the Rails server:
```bash
rails server
```

The application will run at `http://localhost:3000`

## Features

### User Authentication
- Sign up with Clerk
- Sign in to your account
- Sign out functionality

### Event Voting
- View all available events
- See vote counts for each event
- Vote (upvote) or unvote on events
- View event details

## How to Use

### 1. Sign Up
- Go to `http://localhost:3000/sign-up`
- Fill in your details using the sign-up form
- You will be logged in automatically

### 2. Sign In
- Go to `http://localhost:3000/sign-in`
- Enter your credentials
- You will be logged in and redirected to events page

### 3. Browse Events
- After signing in, you'll see the events list at `http://localhost:3000`
- Each event shows the number of votes it has received
- Click on an event to view more details

### 4. Vote on Events
- On the events page or event detail page, click "Vote" button to vote for an event
- Click "Unvote" to remove your vote
- Vote counts update in real-time

## Project Structure

```
app/
  controllers/        # Request handlers
  models/            # Database models
  views/             # HTML templates
  middleware/        # Auth middleware

config/
  routes.rb          # URL routing

db/
  migrate/           # Database migrations
  schema.rb          # Database schema

spec/                # Test files
```

## Key Models

- **User**: Represents authenticated users
- **Event**: Event listings
- **Vote**: User votes on events

## Running Tests

```bash
bundle exec rspec
```

## Troubleshooting

If no events appear:
- Events are stored locally in the database
- Add events manually or seed the database
- Create events via Rails console if needed

## Git History

The project has clean, minimal commits showing:
1. User authentication setup
2. Event voting system implementation
3. Test simplification

## Environment

- **Database**: MySQL (development)
- **Authentication**: Clerk SDK with session-based auth
- **Port**: 3000 (default Rails)
