defmodule BitGraphTest do
  use ExUnit.Case

  alias BitGraph.{V, Adjacency}

  describe "BitGraph" do
    test "create graph" do
      graph = BitGraph.new()
      assert graph.vertices.num_vertices == 0
    end

    test "copy graph" do
      edge_data = %{label: "a->b"}
      graph =
        BitGraph.new()
        |> BitGraph.add_vertex(:a, %{label: "a"})
        |> BitGraph.add_vertex(:b, %{label: "b"})
        |> BitGraph.add_edge(:a, :b, edge_data)
      copy = BitGraph.copy(graph)

      assert length(BitGraph.vertices(graph)) == 2
      assert MapSet.size(BitGraph.out_edges(copy, :a)) == 1
      assert MapSet.size(BitGraph.in_edges(copy, :b)) == 1

      assert BitGraph.get_vertex(copy, :a, [:opts, :label]) == "a"
      assert BitGraph.get_vertex(copy, :b, [:opts, :label]) == "b"
      assert BitGraph.get_edge(copy, :a, :b) |> Map.get(:opts) == edge_data
    end

    test "add vertex" do
      graph = BitGraph.new()
      graph = BitGraph.add_vertex(graph, "A")
      assert graph.vertices.num_vertices == 1
      ## Adding existing vertex should not increase the number of vertices
      graph = BitGraph.add_vertex(graph, "A")
      assert graph.vertices.num_vertices == 1
      ## Adding a new vertex should increase the number of vertices
      graph = BitGraph.add_vertex(graph, "B")
      assert graph.vertices.num_vertices == 2
    end

    test "get/update vertex info" do
      graph = BitGraph.new()
      vertex_data = [label: "a", weight: 1]
      graph = BitGraph.add_vertex(graph, :a, vertex_data)
      assert BitGraph.get_vertex(graph, :a, [:opts]) == vertex_data
       and BitGraph.get_vertex(graph, :a, [:opts, :weight]) == 1
       and BitGraph.get_vertex(graph, :a, [:vertex]) == :a
      refute BitGraph.get_vertex(graph, :a, [:something])

      updated_data = [label: "a2", weight: 2]
      graph = BitGraph.update_vertex(graph, :a, updated_data)
      assert BitGraph.get_vertex(graph, :a, [:opts]) == updated_data

      ## Vertex not in graph
      refute BitGraph.get_vertex(graph, :c)
      refute BitGraph.update_vertex(graph, :c, vertex_data)
    end

    test "add edge" do
      graph = BitGraph.new()
      graph = BitGraph.add_edge(graph, "A", "B")
      assert BitGraph.in_edges(graph, "A") == MapSet.new([])
      [a_b_edge] = BitGraph.in_edges(graph, "B") |> MapSet.to_list()
      assert a_b_edge.from == "A"
      assert a_b_edge.to == "B"
      graph = BitGraph.add_edge(graph, "B", "A")
      [b_a_edge] = BitGraph.out_edges(graph, "B") |> MapSet.to_list()
      assert b_a_edge.from == "B"
      assert b_a_edge.to == "A"
      assert 2 == BitGraph.edges(graph, "A") |> MapSet.size()
      assert 2 == BitGraph.edges(graph, "B") |> MapSet.size()
    end

    test "delete edge" do
      graph = BitGraph.new()
      graph = BitGraph.add_edge(graph, :v1, :v2)
      assert map_size(graph.edges) == 1
      assert adjacent_vertices?(graph, :v1, :v2)
      ## Try to delete non-existing edge
      graph = BitGraph.delete_edge(graph, :v1, :v3)
      assert map_size(graph.edges) == 1
      ## Delete existing edge
      graph = BitGraph.delete_edge(graph, :v1, :v2)
      assert map_size(graph.edges) == 0
      refute adjacent_vertices?(graph, :v1, :v2)
    end

    test "delete vertex" do
      graph = BitGraph.new()
      graph = BitGraph.add_edge(graph, :a, :b)
      assert graph.vertices.num_vertices == 2
      assert map_size(graph.edges) == 1

      assert adjacent_vertices?(graph, :a, :b)

      graph = BitGraph.delete_vertex(graph, :b)
      assert graph.vertices.num_vertices == 1
      assert map_size(graph.edges) == 0
      refute adjacent_vertices?(graph, :a, :b)

    end

    test "neighbors" do
      graph = BitGraph.new()
      graph = BitGraph.add_edge(graph, :a, :b)
      assert BitGraph.in_neighbors(graph, :a) == MapSet.new([])
      assert BitGraph.out_neighbors(graph, :a) == MapSet.new([:b])
      assert BitGraph.in_neighbors(graph, :b) == MapSet.new([:a])
      assert BitGraph.out_neighbors(graph, :b) == MapSet.new([])
      ## Vertex not in graph
      assert BitGraph.in_neighbors(graph, :c) == MapSet.new([])
      assert BitGraph.out_neighbors(graph, :c) == MapSet.new([])
    end

    test "degrees" do
      graph = BitGraph.new()
      graph = BitGraph.add_edge(graph, :a, :b)
      assert BitGraph.in_degree(graph, :a) == 0
      assert BitGraph.out_degree(graph, :a) == 1
      assert BitGraph.in_degree(graph, :b) == 1
      assert BitGraph.out_degree(graph, :b) == 0
      ## Vertex not in graph
      assert BitGraph.in_degree(graph, :c) == 0
      assert BitGraph.out_degree(graph, :c) == 0
    end

    defp adjacent_vertices?(graph, v1, v2) do
      graph[:adjacency]
      |> Adjacency.get(V.get_vertex_index(graph, v1),
      V.get_vertex_index(graph, v2)
      ) == 1
    end

  end
end
