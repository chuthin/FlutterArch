import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:styled_widget/styled_widget.dart';

import 'main.dart';

class GithubEnviroment {
  Future<List<Repo>> getRepo(String query, int page) async {
    final dio = Dio();
    String url =
        'https://api.github.com/search/repositories?q=$query&page=$page&per_page=20';
    // ignore: avoid_print
    print(url);
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return QueryResult.fromJson(response.data).items;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return Future<List<Repo>>.value([]);
    }
  }

  void getRepo2(String query, int page, DataCallback<List<Repo>> result) async {
    var response = await getRepo(query, page);
    result(response);
  }
}

typedef DataCallback<T> = void Function(T);

class QueryResult {
  final int totalCount;
  final List<Repo> items;

  QueryResult({required this.totalCount, required this.items});
  factory QueryResult.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<Repo> queryItems = list.map((i) => Repo.fromJson(i)).toList();
    return QueryResult(
      totalCount: json['total_count'],
      items: queryItems,
    );
  }
}

class Repo {
  final String fullName;

  Repo({required this.fullName});

  factory Repo.fromJson(Map<String, dynamic> json) {
    return Repo(fullName: json['full_name']);
  }
}

class GithubState {
  String query;
  List<Repo> repos;
  int page;
  bool isLoading = false;
  GithubState({required this.query, required this.repos, required this.page});

  @override
  String toString() {
    // TODO: implement toString
    return "$query $page ${repos.length}";
  }
}

class GithubAction {}

class GithubActionLoadMore extends GithubAction {}

class GithubActionQuery extends GithubAction {
  String query;
  GithubActionQuery({required this.query});
}

class GithubActionRepos extends GithubAction {
  List<Repo> repos;
  String query;
  GithubActionRepos({required this.repos, required this.query});
}

GithubState githubReducer(GithubState state, GithubAction action) {
  if (action is GithubActionRepos) {
    if (state.page == 1) {
      state.repos = action.repos;
      state.page = 2;
    } else {
      state.repos = state.repos + action.repos;
      state.page = state.page + 1;
    }
    state.isLoading = false;
  }

  if (action is GithubActionQuery) {
    state.query = action.query;
    state.page = 1;
  }
  return state;
}

GithubState githubEffect(GithubEnviroment? enviroment, GithubState state,
    GithubAction action, Handle<GithubAction> actionResult) {
  if ((action is GithubActionQuery || action is GithubActionLoadMore) &&
      enviroment != null &&
      !state.isLoading) {
    state.isLoading = true;
    enviroment.getRepo2(state.query, state.page, (items) {
      actionResult(GithubActionRepos(repos: items, query: state.query));
    });
  }
  return state;
}

class GithubSearchView extends BaseView<GithubState, GithubAction> {
  const GithubSearchView(
      {super.key, required super.state, required super.handle});

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Github Search"),
        ),
        body: Column(
          children: [
            TextField(
              onSubmitted: (value) {
                handle(GithubActionQuery(query: value));
              },
            ),
            Stack(
              children: [
                streamBuilder(state.map((event) => event.repos))(
                    (context, snapshot) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildObjectItemView(
                                  context,
                                  snapshot.data[index],
                                  index == snapshot.data.length - 1)
                              .gestures(
                            onTap: () {
                              GoRouter.of(context).push(
                                  '/github/detail/${base64.encode(utf8.encode(snapshot.data[index].fullName))}');
                            },
                          );
                        });
                  } else {
                    return const Center(child: Text("Empty data"));
                  }
                }),
                streamBuilder(state.map((value) => value.isLoading))(
                    (context, snapshot) {
                  return Visibility(
                      visible: snapshot.data ?? false,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          Text(" loading...")
                        ],
                      ).backgroundColor(Colors.grey).width(140).height(100)));
                }),
              ],
            ).expanded(),
          ],
        ));
  }

  Widget buildObjectItemView(BuildContext context, Repo repo, bool isLast) {
    if (isLast) {
      handle(GithubActionLoadMore());
    }
    return Text(repo.fullName).height(50);
  }
}

GithubSearchView createGithubSearchView(
    BehaviorSubject<GithubState> state, Handle<GithubAction> handle) {
  return GithubSearchView(state: state, handle: handle);
}

abstract class BaseView<State, Action> extends StatelessWidget {
  final BehaviorSubject<State> state;
  final Handle<Action> handle;
  const BaseView({super.key, required this.state, required this.handle});
}

TaskEither<String, String> getData() {
  return TaskEither<String, String>.tryCatch(
      () async => "demo", (error, stackTrace) => "deni");
}

abstract class Network {
  TaskEither<String, String> getdata(String url);
}

class MyNetwork extends Network {
  @override
  TaskEither<String, String> getdata(String url) {
    return TaskEither<String, String>.tryCatch(
        () async => "response: $url", (error, stackTrace) => "error");
  }
}

Reader<Network, TaskEither<String, String>> getDataReder(String url) {
  return Reader((r) => r.getdata(url));
}

class GithubDetailView extends StatelessWidget {
  final String repo;
  const GithubDetailView({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiet"),
      ),
      body: Center(
        child: Text(repo),
      ),
    );
  }
}
