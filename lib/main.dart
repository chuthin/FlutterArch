import 'package:demoapp/home.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:styled_widget/styled_widget.dart';

import 'appRouter.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: approute,
    );

    /*return const MaterialApp(
      home: HomeScreen(),
      routes: {
      "second":(context)=> const HomeScreen(),
    },
    );*/
  }
}

Widget spacer() {
  return const SizedBox(
    width: 24,
    height: 24,
  );
}

typedef AsyncWidgetBuilderCallback<T> = Widget Function(
    AsyncWidgetBuilder<T> builder);

AsyncWidgetBuilderCallback streamBuilder<T>(Stream<T>? stream) {
  return (builder) {
    return StreamBuilder(stream: stream, builder: builder);
  };
}

ButtonCallback buton([String? text]) {
  return ([VoidCallback? onpress]) {
    return ElevatedButton(
      onPressed: onpress,
      child: Text(text ?? ""),
    );
  };
}

typedef ButtonCallback = ElevatedButton Function([VoidCallback? callback]);

extension ElevatedButtonStyle on ElevatedButton {
  Widget onPress(VoidCallback? callback) {
    return gestures(onTap: callback);
  }
}

StackViewInfo hstack(List<Widget> children) {
  return (
      [MainAxisAlignment? mainAxisAlignment,
      MainAxisSize? mainAxisSize,
      CrossAxisAlignment? crossAxisAlignment,
      TextDirection? textDirection,
      VerticalDirection? verticalDirection,
      TextBaseline? textBaseline,
      Widget? separator]) {
    return children.toRow(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        textDirection: textDirection,
        verticalDirection: verticalDirection ?? VerticalDirection.down,
        textBaseline: textBaseline,
        separator: separator);
  };
}

StackViewInfo vstack(List<Widget> children) {
  return (
      [MainAxisAlignment? mainAxisAlignment,
      MainAxisSize? mainAxisSize,
      CrossAxisAlignment? crossAxisAlignment,
      TextDirection? textDirection,
      VerticalDirection? verticalDirection,
      TextBaseline? textBaseline,
      Widget? separator]) {
    return children.toColumn(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        textDirection: textDirection,
        verticalDirection: verticalDirection ?? VerticalDirection.down,
        textBaseline: textBaseline,
        separator: separator);
  };
}

typedef StackViewInfo = Widget Function(
    [MainAxisAlignment mainAxisAlignment,
    MainAxisSize mainAxisSize,
    CrossAxisAlignment crossAxisAlignment,
    TextDirection? textDirection,
    VerticalDirection verticalDirection,
    TextBaseline? textBaseline,
    Widget? separator]);

typedef StringCallback = String Function([String name]);

StringCallback curry(String firstName) {
  return ([String? lastName]) {
    return '$firstName ${lastName ?? "dev"}';
  };
}

typedef Handle<A> = void Function(A action);
typedef Builder<S, A, V> = V Function(
    BehaviorSubject<S> state, Handle<A> handle);
typedef Reducer<S, A> = S Function(S state, A action);
typedef Effect<E, S, A> = S Function(
    E? enviroment, S state, A action, Handle<A> actionResult);

class RenderObject<E, S> {
  final BehaviorSubject<S> state;
  final E? environment;

  const RenderObject({required this.state, this.environment});
  V expo<A, V>(Builder<S, A, V> builder, Reducer<S, A> reducer,
      Effect<E, S, A>? effect) {
    actionFNC(action) {
      this.state.add(reducer(this.state.value, action));
    }

    return builder(state, (action) {
      var state = reducer(this.state.value, action);
      if (effect != null) {
        state = effect(this.environment, this.state.value, action, actionFNC);
      }
      this.state.add(state);
    });
  }
}

class StoreView<S, A, V extends Widget, E> extends StatelessWidget {
  final RenderObject<E, S> render;
  final Builder<S, A, V> builder;
  final Reducer<S, A> reducer;
  final Effect<E, S, A>? effect;

  const StoreView(
      {super.key,
      required this.render,
      required this.reducer,
      required this.builder,
      this.effect});

  @override
  Widget build(BuildContext context) {
    return render.expo(builder, reducer, effect);
  }
}

StoreView<S, A, V, E> createStoreView<S, A, V extends Widget, E>(
    E? enviroment,
    S state,
    Builder<S, A, V> builder,
    Reducer<S, A> reducer,
    Effect<E, S, A>? effect) {
  return StoreView(
    render: RenderObject<E, S>(
        state: BehaviorSubject<S>.seeded(state), environment: enviroment),
    reducer: reducer,
    builder: builder,
    effect: effect,
  );
}

mixin Network {
  void getData(String url) {
    print("Network get data $url");
  }
}

mixin Database {
  void readData(String query) {
    print("Database read date $query");
  }
}

class GHEnviroment with Network, Database {}
