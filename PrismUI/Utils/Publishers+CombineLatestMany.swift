//
//  Publishers+CombineLatestMany.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/26/21.
//

import Combine

extension Publisher {
    public func combineLatest<P, Q, R, S, Y>(
        _ publisher1: P,
        _ publisher2: Q,
        _ publisher3: R,
        _ publisher4: S,
        _ publisher5: Y) ->
    AnyPublisher<(Self.Output,
                  P.Output,
                  Q.Output,
                  R.Output,
                  S.Output,
                  Y.Output),
                 Self.Failure> where P: Publisher, Q: Publisher, R: Publisher, S: Publisher, Y: Publisher,
    Self.Failure == P.Failure,
    P.Failure == Q.Failure,
    Q.Failure == R.Failure,
    R.Failure == S.Failure,
    S.Failure == Y.Failure {
        Publishers.CombineLatest(combineLatest(publisher1, publisher2, publisher3), combineLatest(publisher4, publisher5)).map { tuple, tuple2 in
            (tuple.0, tuple.1, tuple.2, tuple.3, tuple2.1, tuple2.2)
        }.eraseToAnyPublisher()
    }

    public func combineLatest<P, Q, R, S, Y, Z>(
        _ publisher1: P,
        _ publisher2: Q,
        _ publisher3: R,
        _ publisher4: S,
        _ publisher5: Y,
        _ publisher6: Z) ->
    AnyPublisher<(Self.Output,
                  P.Output,
                  Q.Output,
                  R.Output,
                  S.Output,
                  Y.Output,
                  Z.Output),
                 Self.Failure> where P: Publisher, Q: Publisher, R: Publisher, S: Publisher, Y: Publisher, Z: Publisher,
    Self.Failure == P.Failure,
    P.Failure == Q.Failure,
    Q.Failure == R.Failure,
    R.Failure == S.Failure,
    S.Failure == Y.Failure,
    Y.Failure == Z.Failure {
        Publishers.CombineLatest(combineLatest(publisher1, publisher2, publisher3), combineLatest(publisher4, publisher5, publisher6)).map { tuple, tuple2 in
            (tuple.0, tuple.1, tuple.2, tuple.3, tuple2.1, tuple2.2, tuple2.3)
        }.eraseToAnyPublisher()
    }
}
