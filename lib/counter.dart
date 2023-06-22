import 'package:demoapp/main.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:styled_widget/styled_widget.dart';

CounterSate counterReducer(CounterSate state, CounterAction action) {
  switch (action) {
    case CounterAction.increment:
      {
        return CounterSate(count: state.count + 1);
      }
    case CounterAction.decrement:
      {
        return CounterSate(count: state.count - 1);
      }
  }
}

class CounterSate {
  int count;
  CounterSate({required this.count});
}

enum CounterAction { increment, decrement }

class CounterView extends StatelessWidget {
  final BehaviorSubject<CounterSate> state;
  final Handle<CounterAction> handle;
  const CounterView({super.key, required this.state, required this.handle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          streamBuilder(state.map((event) => event.count))(
            (_, snapshot) {
              return Text(
                curry('You have pushed the button ${snapshot.data} times:')(),
              ).alignment(Alignment.center);
            },
          ),
          spacer(),
          hstack([
            buton("Decrement")(() => handle(CounterAction.decrement))
                .padding(left: 24)
                .expanded(),
            spacer(),
            buton("Increment")(() => handle(CounterAction.increment))
                .padding(right: 24)
                .expanded(),
          ])(MainAxisAlignment.spaceEvenly),
          const SizedBox().expanded(),
        ],
      ),
    );
  }
}

CounterView createCounterView(
    BehaviorSubject<CounterSate> state, Handle<CounterAction> handle) {
  return CounterView(state: state, handle: handle);
}
