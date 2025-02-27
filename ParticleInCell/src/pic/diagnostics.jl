import Diagnostics
struct ParticleVectorData <: Diagnostics.DiagnosticData
   x :: Array{Float64,1}
   y :: Array{Float64,1}
   u :: Array{Float64,1}
   v :: Array{Float64,1}
   w :: Array{Float64,1}
  id :: Array{UInt64,1}
end
ParticleVectorData(x,u,id,np) =
ParticleVectorData(x[1:np,1], x[1:np,2], u[1:np,1], u[1:np,2], zeros(np), id[1:np])

struct NodeData <: Diagnostics.DiagnosticData
  u :: Array{Float64,2}
 or :: Array{Float64,1}
 sp :: Array{Float64,1}
end

struct GridData <: Diagnostics.DiagnosticData
  u :: Array{Float64,3}
  x :: Array{Float64,2}
  y :: Array{Float64,2}
end

import PlotVTK: pvd_add_timestep, field_as_points, field_as_vectors, field_as_grid, field_as_vectors
Diagnostics.save_diagnostic(dname::String, d::ParticleVectorData, cname::String, c::Any, it::Integer) =
  pvd_add_timestep(c, field_as_vectors(d.x, d.y, dname, dname => (d.u, d.v, d.w), "uuid" => (d.id,), it=it, save=false), it)
Diagnostics.save_diagnostic(dname::String, d::NodeData, cname::String, c::Any, it::Integer) =
  pvd_add_timestep(c, field_as_points(dname  => d.u, dname, spacing=d.sp, origin=d.or, it=it, save=false), it)
Diagnostics.save_diagnostic(dname::String, d::GridData, cname::String, c::Any, it::Integer) =
  pvd_add_timestep(c, field_as_grid(d.x, d.y, dname  => d.u, dname, it=it, save=false), it)
