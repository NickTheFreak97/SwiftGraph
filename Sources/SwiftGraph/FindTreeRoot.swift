import Foundation

fileprivate class UnionFind {
    private var parent: [Int]
    private var rank: [Int]
    
    init(elements: [Int]) {
        self.parent = [Int].init(repeating: 0, count: elements.count)
        self.rank = [Int].init(repeating: 0, count: elements.count)
        
        self.makeSet(elements)
    }

    private final func makeSet(_ vertices: [Int]) {
        for i in 0..<vertices.count {
            parent[i] = i
            rank[i] = 0
        }
    }

    func find(_ x: Int) -> Int {
        if parent[x] != x {
            parent[x] = find(parent[x]) // Path compression
        }
        return parent[x]
    }

    func union(_ x: Int, _ y: Int) {
        let xRoot = find(x)
        let yRoot = find(y)
        
        if xRoot == yRoot {
            return
        }
        
        if rank[xRoot] < rank[yRoot] {
            parent[xRoot] = yRoot
        } else if rank[xRoot] > rank[yRoot] {
            parent[yRoot] = xRoot
        } else {
            parent[yRoot] = xRoot
            rank[xRoot] += 1
        }
    }
}


extension Graph {
    
    /// Finds all edges in the same connected component as the given vertex using Union-Find.
    ///
    /// - Parameter vertexIndex: The index of the vertex whose connected component edges you want to find.
    /// - Returns: An array of all edges in the same connected component as the vertex, or an empty array
    ///            if the vertex index is out of bounds.
    ///
    /// - Complexity: **Time:** O(V + E⋅α(V)) where α(V) is the inverse Ackermann function.
    ///               **Memory:** O(V) for the Union-Find structure.
    public func edgesInComponent(ofVertexAt vertexIndex: Int) -> [E] {
        guard vertexIndex >= 0 && vertexIndex < vertices.count else {
            return []
        }
        
        let unionFind = UnionFind(elements: [Int](self.vertices.indices))
        
        for vertex in 0..<self.vertices.count {
            for edge in self.edges[vertex] {
                unionFind.union(vertex, edge.v)
            }
        }
        
        let targetComponent = unionFind.find(vertexIndex)
        var componentEdges: [E] = []
        
        for vertex in 0..<self.vertices.count {
            if unionFind.find(vertex) == targetComponent {
                for edge in self.edges[vertex] {
                    if edge.directed || edge.v >= edge.u {
                        componentEdges.append(edge)
                    }
                }
            }
        }
        
        return componentEdges
    }
    
    /// Finds all edges in the same connected component as the given vertex using Union-Find.
    ///
    /// This is a convenience method that accepts a vertex value instead of an index.
    ///
    /// - Parameter vertex: The vertex whose connected component edges you want to find.
    /// - Returns: An array of all edges in the same connected component as the vertex, or `nil`
    ///            if the vertex is not found in the graph.
    ///
    /// - Complexity: **Time:** O(V + E⋅α(V)) where α(V) is the inverse Ackermann function.
    ///               **Memory:** O(V) for the Union-Find structure.
    public func edgesInComponent(ofVertex vertex: V) -> [E]? {
        guard let index = indexOfVertex(vertex) else {
            return nil
        }
        
        return edgesInComponent(ofVertexAt: index)
    }
    
    
    /// Finds all connected components in graph using Union-Find.
    ///
    ///
    /// - Returns: A 2D array whose rows are indices of vertices that make up a connected component in the graph.
    ///
    /// - Complexity: **Time:** O(V + E⋅α(V)) where α(V) is the inverse Ackermann function.
    ///               **Memory:** O(V) for the Union-Find structure
    public func connectedComponents() -> [[Int]] {
        let unionFind = UnionFind(elements: [Int](self.vertices.indices))
        for vertex in 0..<self.vertices.count {
            for edge in self.edges[vertex] {
                unionFind.union(vertex, edge.v)
            }
        }

        var componentsByRoot: [Int: [Int]] = [:]
        for vertex in 0..<self.vertices.count {
            componentsByRoot[unionFind.find(vertex), default: []].append(vertex)
        }
        return Array(componentsByRoot.values)
    }

    
    /// Finds all connected components in graph using Union-Find.
    ///
    ///
    /// - Returns: A 2D array whose elements are the vertices that make up a connected component in the graph.
    ///
    /// - Complexity: **Time:** O(V + E⋅α(V)) where α(V) is the inverse Ackermann function.
    ///               **Memory:** O(V) for the Union-Find structure
    public func connectedComponentVertices() -> [[V]] {
        self.connectedComponents().map { $0.map { self.vertexAtIndex($0) } }
    }
    
    /// Finds the root vertex (vertex with indegree 0) in the same connected component as the given vertex.
    ///
    /// Note: BFS/DFS can't "climb up" directed edges (they only follow outgoing edges), and UnionFind
    /// only tracks connectivity, not directional structure. This method uses UnionFind to identify
    /// the component, then finds the vertex with indegree 0.
    ///
    /// Since UnionFind groups vertices by connectivity, any edge pointing to a vertex must come from
    /// another vertex in the same component. Therefore, indegree within the component equals total indegree.
    ///
    /// - Parameter vertexIndex: The index of the vertex whose component root you want to find.
    /// - Returns: The index of the root vertex (indegree 0) in the same component, or `nil` if
    ///            the vertex is out of bounds, no root exists (cycle), or multiple roots exist.
    ///
    /// - Complexity: **Time:** O(V² + E⋅α(V)) due to indegree checks. **Memory:** O(V).
    public func rootOfComponent(containingVertexAt vertexIndex: Int) -> Int? {
        guard vertexIndex >= 0 && vertexIndex < vertices.count else {
            return nil
        }

        let unionFind = UnionFind(elements: [Int](self.vertices.indices))
        var indegree = [Int](repeating: 0, count: self.vertices.count)

        for vertex in 0..<self.vertices.count {
            for edge in self.edges[vertex] {
                unionFind.union(vertex, edge.v)
                indegree[edge.v] += 1
            }
        }

        let targetComponent = unionFind.find(vertexIndex)
        let roots = self.vertices.indices.filter {
            unionFind.find($0) == targetComponent && indegree[$0] == 0
        }
        return roots.count == 1 ? roots.first : nil
    }
    
    /// Finds the root vertex (vertex with indegree 0) in the same connected component as the given vertex.
    ///
    /// - Parameter vertex: The vertex whose component root you want to find.
    /// - Returns: The root vertex, or `nil` if not found or no unique root exists.
    public func rootOfComponent(containingVertex vertex: V) -> V? {
        guard let index = indexOfVertex(vertex),
              let rootIndex = rootOfComponent(containingVertexAt: index) else {
            return nil
        }
        return self.vertices[rootIndex]
    }
}
