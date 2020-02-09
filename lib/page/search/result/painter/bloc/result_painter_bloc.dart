import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/network/api_client.dart';

import './bloc.dart';

class ResultPainterBloc extends Bloc<ResultPainterEvent, ResultPainterState> {
  final ApiClient client;

  ResultPainterBloc(this.client);
  @override
  ResultPainterState get initialState => InitialResultPainterState();

  @override
  Stream<ResultPainterState> mapEventToState(
    ResultPainterEvent event,
  ) async* {
    if (event is FetchEvent) {
      try {
        Response response = await client.getSearchUser(event.word);
        UserPreviewsResponse userPreviewsResponse =
            UserPreviewsResponse.fromJson(response.data);
        yield ResultPainterDataState(
            userPreviewsResponse.user_previews, userPreviewsResponse.next_url);
        yield RefreshSuccessState();
      } catch (e) {
        yield RefreshFailState();
      }
    }
    if (event is LoadMoreEvent) {
      if (event.nextUrl != null && event.nextUrl.isNotEmpty) {
        try {
          Response response = await client.getNext(event.nextUrl);
          UserPreviewsResponse userPreviewsResponse =
              UserPreviewsResponse.fromJson(response.data);
          yield ResultPainterDataState(userPreviewsResponse.user_previews,
              userPreviewsResponse.next_url);
          yield LoadMoreSuccessState();
        } catch (e) {
        yield LoadMoreFailState();
        }
      }
      else{
        yield LoadEndState();
      }
    }
  }
}
