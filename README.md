# Posts Manager

A Flutter mobile application for managing posts REST API.
Built for Lab 4 — Consuming APIs in Flutter.

## Features

- View all posts in a searchable, scrollable list
- Read the full content of any post
- Create a new post
- Edit an existing post
- Delete a post (swipe left or from the detail screen)
- Pull-to-refresh to reload from the API
- Optimistic UI updates with undo support on delete
- Skeleton loading screen (custom shimmer, no third-party package)
- Smooth fade-and-slide page transitions

## API

All data is fetched from and sent to:

```
https://jsonplaceholder.typicode.com/posts
```

Endpoints used: `GET /posts`, `GET /posts/:id`, `POST /posts`, `PUT /posts/:id`, `DELETE /posts/:id`

## Architecture

```
lib/
  main.dart                        Entry point, ChangeNotifierProvider setup
  app.dart                         MaterialApp, named routes, global transitions
  theme/
    app_colors.dart                Color constants (steel-blue palette)
    app_theme.dart                 Material3 ThemeData factory
  models/
    post.dart                      Immutable Post model with JSON serialization
  services/
    api_service.dart               HTTP client wrapper, ApiException type
  providers/
    posts_provider.dart            ChangeNotifier: state, filtering, optimistic CRUD
  screens/
    posts_list_screen.dart         List with search, swipe-delete, pull-to-refresh
    post_detail_screen.dart        Read-only detail, edit/delete actions
    post_form_screen.dart          Shared create / edit form
  widgets/
    post_card.dart                 List card with ID badge, optimistic pulse animation
    skeleton_card.dart             ShimmerPainter (CustomPainter, no shimmer package)
    skeleton_list.dart             7 staggered skeleton cards
    character_count_field.dart     TextFormField with live character counter
    search_bar_widget.dart         Debounced search input with result count
    fade_slide_route.dart          Custom PageRouteBuilder (fade + slide)
```

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `http` | ^1.2.1 | HTTP requests to JSONPlaceholder API |
| `provider` | ^6.1.2 | State management (ChangeNotifier pattern) |

## Setup

```bash
flutter pub get
flutter run
```



