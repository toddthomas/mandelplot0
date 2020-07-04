//
//  main.swift
//  mandelplot0
//
//  Created by Todd Thomas on 7/3/20.
//  Copyright © 2020 Todd Thomas. All rights reserved.
//

import ComplexModule
import Foundation
import RealModule

typealias Complex = ComplexModule.Complex<Double>

typealias Func<Number> = (Number) -> Number

func f<Number: Numeric>(c: Number) -> Func<Number> {
    { x in
        x*x + c
    }
}

struct IteratedFuncValues<Number: Numeric> {
    let f: Func<Number>
    var iterations: Int
    var currentValue = Number.zero
}

extension IteratedFuncValues: Sequence, IteratorProtocol {
    mutating func next() -> Number? {
        if iterations > 0 {
            currentValue = f(currentValue)
            iterations -= 1
            return currentValue
        } else {
            return nil
        }
    }
}

protocol Lengthy: Numeric {
    var length: Magnitude { get }
}

extension Lengthy {
    var length: Magnitude {
        magnitude
    }
}

extension Int: Lengthy {}
extension Double: Lengthy {}

extension Lengthy {
    var twoOrLess: Bool {
        length <= 2
    }
}

extension IteratedFuncValues where Number: Lengthy {
    var bounded: Bool {
        allSatisfy(\.twoOrLess)
    }
}

struct PlotPoints<Number> where Number: AlgebraicField { // Change constraint to `AlgebraicField`
    typealias Index = Int

    let start: Number
    let end: Number
    let pointCount: Index
    let step: Number


    init(from start: Number, to end: Number, pointCount: Index) {
        self.start = start
        self.end = end
        self.pointCount = pointCount
        self.step = (end - start) / Number(exactly: pointCount - 1)! // Change initializer.
    }
}

extension PlotPoints: Collection {
    typealias Element = Number
    typealias Indices = Range<Int>

    var startIndex: Index { 0 }

    var endIndex: Index { pointCount }

    var indices: Indices { 0..<pointCount }

    subscript(position: Index) -> Element {
        start + step * Number(exactly: position)! // Change initializer.
    }

    func index(after i: Index) -> Index {
        i + 1
    }
}

func plotValue(for predicate: Bool) -> Character {
    predicate ? Character("*") : Character(" ")
}

func renderIndices<Number>(_ indices: [Number], for points: PlotPoints<Number>) -> String where Number: CVarArg, Number: Comparable {
    var renderedIndices = ""
    var indexIterator = indices.sorted().makeIterator()
    var currentIndex = indexIterator.next()

    while renderedIndices.count < points.count {
        guard let index = currentIndex else { break }
        let plotPoint = points[renderedIndices.count]
        if plotPoint >= index {
            renderedIndices.append(String(format: "|%.2f", plotPoint))
            currentIndex = indexIterator.next()
        } else {
            renderedIndices.append(" ")
        }
    }

    return renderedIndices
}

struct ComplexPlotPoints<RealType: Real> {
    typealias SomeComplex = ComplexModule.Complex<RealType>
    typealias Index = Int

    let upperLeft: SomeComplex
    let lowerRight: SomeComplex
    let horizontalPointCount: Index
    let verticalPointCount: Index
    let verticalStep: RealType

    init(from upperLeft: SomeComplex, to lowerRight: SomeComplex, horizontalPointCount: Index, verticalPointCount: Index) {
        self.upperLeft = upperLeft
        self.lowerRight = lowerRight
        self.horizontalPointCount = horizontalPointCount
        self.verticalPointCount = verticalPointCount

        verticalStep = (upperLeft.imaginary - lowerRight.imaginary) / RealType((verticalPointCount - 1))
    }
}

extension ComplexPlotPoints: Collection {
    typealias Element = PlotPoints<SomeComplex>
    typealias Indices = Range<Int>

    var startIndex: Index { 0 }

    var endIndex: Index { verticalPointCount }

    var indices: Indices { 0..<verticalPointCount }

    subscript(position: Index) -> Element {
        let imaginaryPart = upperLeft.imaginary - verticalStep * RealType(position)
        return PlotPoints(from: SomeComplex(upperLeft.real, imaginaryPart), to: SomeComplex(lowerRight.real, imaginaryPart), pointCount: horizontalPointCount)
    }

    func index(after i: Index) -> Index {
        i + 1
    }
}

extension ComplexModule.Complex: Lengthy {}

let mandelPoints = ComplexPlotPoints(from: Complex(-3.0, 2.0), to: Complex(1.0, -2.0), horizontalPointCount: 50, verticalPointCount: 50)

let mandelPlot = mandelPoints.map { points in
    points.map { point in
        plotValue(for: IteratedFuncValues(f: f(c: point), iterations: 30).bounded)
    }
}

for row in mandelPlot {
    print(String(row))
}

extension ComplexPlotPoints {
    var realPoints: PlotPoints<RealType> {
        PlotPoints(from: upperLeft.real, to: lowerRight.real, pointCount: horizontalPointCount)
    }
}

for (i, row) in mandelPlot.enumerated() {
    print(String(row) + "|\(mandelPoints[i].first!.imaginary)")
}

let interestingIndices = [-3.0, -2.0, -1.0, -0.75, 0.0, 0.25, 0.5, 1.0]
print(renderIndices(interestingIndices, for: mandelPoints.realPoints))

let moreMandelPoints = ComplexPlotPoints(from: Complex(-3.0, 1.0), to: Complex(1.0, -1.0), horizontalPointCount: 110, verticalPointCount: 55)

let moreMandelPlot = moreMandelPoints.map { points in
    points.map { point in
        plotValue(for: IteratedFuncValues(f: f(c: point), iterations: 30).bounded)
    }
}

for (i, row) in moreMandelPlot.enumerated() {
    print(String(row) + "|\(moreMandelPoints[i].first!.imaginary)")
}

print(renderIndices(interestingIndices, for: moreMandelPoints.realPoints))

let bestMandelPoints = ComplexPlotPoints(from: Complex(-3.0, 1.0), to: Complex(1.0, -1.0), horizontalPointCount: 220, verticalPointCount: 55)

let bestMandelplot = bestMandelPoints.map { points in
    points.map { point in
        plotValue(for: IteratedFuncValues(f: f(c: point), iterations: 30).bounded)
    }
}

print("Best mandelplot!")
for row in bestMandelplot {
    print(String(row))
}
