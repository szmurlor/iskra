module PlotVTK
  using WriteVTK
  using Printf

  export field_as_vectors
  export field_as_points
  export field_as_grid
  export pvd_save
  export pvd_create
  export pvd_add_timestep

  function pvd_create(filename::String)
    pvd = paraview_collection(filename)
  end

  function pvd_add_timestep(pvd, vtkfile, time)
    collection_add_timestep(pvd, vtkfile, time)
  end

  function pvd_save(pvd)
    vtk_save(pvd)
  end

  function field_as_points(field::Pair, filename::String; it=nothing, save=true, origin=[0.,0.,0.], spacing=[1.,1.,1.])
    name, data = field
    N = size(data)
    if it != nothing
      filename = @sprintf "%s_%i" filename it
    end
    vtkfile = vtk_grid(filename, N, origin=origin, spacing=spacing)
    vtk_point_data(vtkfile, data, name)

    if save
      vtk_save(vtkfile)
    end

    return vtkfile
  end
 
  function field_as_grid(x::Array, y::Array, field::Pair, filename::String; it=nothing, save=true)
    name, data = field
    if it != nothing
      filename = @sprintf "%s_%i" filename it
    end
    vtkfile = vtk_grid(filename, x, y)

    nx, ny, nc = size(data)
    if nc == 2
      data = cat(data, zeros(nx, ny); dims=3)
      nc = 3
    end

    data = permutedims(reshape(data, nx, ny, nc, 1), [3,1,2,4])
    vtk_point_data(vtkfile, data, name)

    if save
      vtk_save(vtkfile)
    end

    return vtkfile
  end


  function field_as_vectors(x::AbstractArray{Float64,1}, y::AbstractArray{Float64,1},
                   filename::String, data::Pair...; it=nothing, save=true)
    if it != nothing
      filename = @sprintf "%s_%i" filename it
    end

    cells = Array{MeshCell{Array{Int64,1}},1}()

    for i=1:length(x)
      cell = MeshCell(VTKCellTypes.VTK_VERTEX, [i])
      push!(cells, cell)
    end

    vtkfile = vtk_grid(filename, x, y, cells)
    for datum in data
      vtk_point_data(vtkfile, datum.second, datum.first)
    end

    if save
      vtk_save(vtkfile)
    end

    return vtkfile
  end
end
