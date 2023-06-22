import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'counter.dart';
import 'githubSearch.dart';
import 'home.dart';
import 'main.dart';

final approute = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    githubRoute,
    GoRoute(
      path: '/counter',
      builder: (context, state) =>
          createStoreView<CounterSate, CounterAction, CounterView, Unit>(null,
              CounterSate(count: 0), createCounterView, counterReducer, null),
    ),
  ],
);

final githubRoute = GoRoute(
  path: '/github',
  builder: (context, state) => createStoreView<GithubState, GithubAction,
          GithubSearchView, GithubEnviroment>(
      GithubEnviroment(),
      GithubState(query: "", repos: [], page: 1),
      createGithubSearchView,
      githubReducer,
      githubEffect),
  routes: [
    GoRoute(
        path: "detail/:repo",
        builder: (context, state) {
          final repo = state.params['repo'];
          return GithubDetailView(
              repo: utf8.decode(base64.decode((repo ?? ""))));
        })
  ],
);
