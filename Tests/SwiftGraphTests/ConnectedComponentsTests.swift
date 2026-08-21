import XCTest
@testable import SwiftGraph

final class ConnectedComponentsTests: XCTestCase {

    // MARK: - connectedComponents()

    func testConnectedComponentsEmptyGraph() {
        let graph = UnweightedGraph<String>()

        let components = graph.connectedComponents()

        XCTAssertTrue(components.isEmpty)
    }

    func testConnectedComponentsSingleVertex() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")

        let components = graph.connectedComponents()

        XCTAssertEqual(normalize(components), [[0]])
    }

    func testConnectedComponentsAllVerticesConnected() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")
        graph.addVertex("D")

        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")
        graph.addEdge(from: "C", to: "D")

        let components = graph.connectedComponents()

        XCTAssertEqual(normalize(components), [[0, 1, 2, 3]])
    }

    func testConnectedComponentsMultipleComponents() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")
        graph.addVertex("D")
        graph.addVertex("E")
        graph.addVertex("F")

        // Component: A - B - C
        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")

        // Component: D - E
        graph.addEdge(from: "D", to: "E")

        // F is isolated.
        let components = graph.connectedComponents()

        XCTAssertEqual(
            normalize(components),
            [
                [0, 1, 2],
                [3, 4],
                [5]
            ]
        )
    }

    func testConnectedComponentsIncludesIsolatedVertices() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")

        graph.addEdge(from: "A", to: "B")

        let components = graph.connectedComponents()

        XCTAssertEqual(
            normalize(components),
            [
                [0, 1],
                [2]
            ]
        )
    }

    func testConnectedComponentsTransitiveConnectivity() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")
        graph.addVertex("D")

        // A is connected to D through B and C.
        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")
        graph.addEdge(from: "C", to: "D")

        let components = graph.connectedComponents()

        XCTAssertEqual(normalize(components), [[0, 1, 2, 3]])
    }

    func testConnectedComponentsWithCycles() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")
        graph.addVertex("D")

        // A - B - C - A
        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")
        graph.addEdge(from: "C", to: "A")

        // D is isolated.
        let components = graph.connectedComponents()

        XCTAssertEqual(
            normalize(components),
            [
                [0, 1, 2],
                [3]
            ]
        )
    }

    func testConnectedComponentsWithDuplicateEdges() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")

        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")

        let components = graph.connectedComponents()

        XCTAssertEqual(normalize(components), [[0, 1, 2]])
    }

    func testConnectedComponentsMergesPreviouslySeparateComponents() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")
        graph.addVertex("D")
        graph.addVertex("E")
        graph.addVertex("F")

        // Three initially separate components:
        // A - B
        // C - D
        // E - F
        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "C", to: "D")
        graph.addEdge(from: "E", to: "F")

        // Merge the components.
        graph.addEdge(from: "B", to: "C")
        graph.addEdge(from: "D", to: "E")

        let components = graph.connectedComponents()

        XCTAssertEqual(
            normalize(components),
            [[0, 1, 2, 3, 4, 5]]
        )
    }

    // MARK: - connectedComponentVertices()

    func testConnectedComponentVerticesEmptyGraph() {
        let graph = UnweightedGraph<String>()

        let components = graph.connectedComponentVertices()

        XCTAssertTrue(components.isEmpty)
    }

    func testConnectedComponentVerticesSingleVertex() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")

        let components = graph.connectedComponentVertices()

        XCTAssertEqual(
            normalize(components),
            [["A"]]
        )
    }

    func testConnectedComponentVerticesReturnsActualVertices() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("Alice")
        graph.addVertex("Bob")
        graph.addVertex("Charlie")
        graph.addVertex("David")

        graph.addEdge(from: "Alice", to: "Bob")
        graph.addEdge(from: "Bob", to: "Charlie")

        let components = graph.connectedComponentVertices()

        XCTAssertEqual(
            normalize(components),
            [
                ["Alice", "Bob", "Charlie"],
                ["David"]
            ]
        )
    }

    func testConnectedComponentVerticesMultipleComponents() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("A")
        graph.addVertex("B")
        graph.addVertex("C")
        graph.addVertex("D")
        graph.addVertex("E")
        graph.addVertex("F")

        graph.addEdge(from: "A", to: "B")
        graph.addEdge(from: "B", to: "C")
        graph.addEdge(from: "D", to: "E")

        let components = graph.connectedComponentVertices()

        XCTAssertEqual(
            normalize(components),
            [
                ["A", "B", "C"],
                ["D", "E"],
                ["F"]
            ]
        )
    }

    func testConnectedComponentVerticesPreservesVertexValues() {
        let graph = UnweightedGraph<String>()
        graph.addVertex("New York")
        graph.addVertex("London")
        graph.addVertex("Tokyo")

        graph.addEdge(from: "New York", to: "London")

        let components = graph.connectedComponentVertices()

        XCTAssertEqual(
            normalize(components),
            [
                ["London", "New York"],
                ["Tokyo"]
            ]
        )
    }

    // MARK: - Helpers

    private func normalize(_ components: [[Int]]) -> [[Int]] {
        components
            .map { $0.sorted() }
            .sorted {
                ($0.first ?? -1) < ($1.first ?? -1)
            }
    }

    private func normalize(_ components: [[String]]) -> [[String]] {
        components
            .map { $0.sorted() }
            .sorted {
                ($0.first ?? "") < ($1.first ?? "")
            }
    }
}
