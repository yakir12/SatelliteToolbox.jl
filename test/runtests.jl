using Test

using Dates
using DelimitedFiles
using LinearAlgebra
using Printf
using ReferenceFrameRotations
using SatelliteToolbox
using SatelliteToolbox.SGP4
using StaticArrays

@testset "Atmospheric Models" verbose=true begin
    cd("./earth/atmospheric_models/expatmosphere/")
    include("./earth/atmospheric_models/expatmosphere/expatmosphere.jl")
    cd("../../../")
    cd("./earth/atmospheric_models/nrlmsise00/")
    include("./earth/atmospheric_models/nrlmsise00/nrlmsise00.jl")
    cd("../../../")
    cd("./earth/atmospheric_models/jb2008/")
    include("./earth/atmospheric_models/jb2008/jb2008.jl")
    cd("../../../")
    cd("./earth/atmospheric_models/jr1971/")
    include("./earth/atmospheric_models/jr1971/jr1971.jl")
    cd("../../../")
end
println("")

@testset "Geomagnetic Field Models" verbose=true begin
    cd("./earth/geomagnetic_field_models/")
    include("./earth/geomagnetic_field_models/dipole.jl")
    include("./earth/geomagnetic_field_models/igrf.jl")
    cd("../../")
end
println("")

@testset "Gravity Field Models" verbose=true begin
    cd("./earth/gravity_models/")
    include("./earth/gravity_models/gravity_models.jl")
    cd("../../")
end
println("")

@testset "Space Indices" verbose=true begin
    cd("./earth/space_indices/")
    include("./earth/space_indices/space_indices.jl")
    cd("../../")
end
println("")

@testset "General orbit functions" verbose=true begin
    include("./orbit/general.jl")
    include("./orbit/representations.jl")
end
println("")

@testset "Conversion from osculating to mean elements" verbose=true begin
    include("./orbit/mean_elements/j2osc.jl")
    include("./orbit/mean_elements/sgp4.jl")
end
println("")

@testset "Orbit propagators" verbose=true begin
    cd("./orbit/propagators")
    include("./orbit/propagators/sgp4.jl")
    include("./orbit/propagators/twobody.jl")
    cd("../../")
end
println("")

@testset "Coordinate transformations" verbose=true begin
    cd("./transformations/fk5/")
    include("./transformations/fk5/fk5.jl")
    cd("../../")
    cd("./transformations/iau2006/")
    include("./transformations/iau2006/iau2006_cio.jl")
    include("./transformations/iau2006/iau2006_equinox.jl")
    include("./transformations/iau2006/nutation_eo.jl")
    include("./transformations/iau2006/precession.jl")
    cd("../../")
    cd("./transformations/teme/")
    include("./transformations/teme/teme.jl")
    cd("../../")
    cd("./transformations/")
    include("./transformations/ecef_to_ecef.jl")
    include("./transformations/ecef_to_eci.jl")
    include("./transformations/eci_to_ecef.jl")
    include("./transformations/eci_to_eci.jl")
    include("./transformations/eop.jl")
    include("./transformations/geodetic_geocentric.jl")
    include("./transformations/local_frame.jl")
    include("./transformations/orbit_elements.jl")
    include("./transformations/sv_ecef_to_ecef.jl")
    include("./transformations/sv_ecef_to_eci.jl")
    include("./transformations/sv_eci_to_ecef.jl")
    include("./transformations/sv_eci_to_eci.jl")
    cd("../")
end
println("")

@testset "Functions related with time" verbose=true begin
     include("./time/raan.jl")
     include("./time/time.jl")
end
println("")

@testset "Functions related with the Sun" verbose=true begin
    include("./sun/equation_of_time.jl")
    include("./sun/sun_position.jl")
    include("./sun/sun_velocity.jl")
end
println("")

@testset "Functions related with the Moon" verbose=true begin
    include("./moon/moon_position.jl")
end
println("")

@testset "Submodules" verbose=true begin
    cd("./submodules/")
    include("./submodules/submodules.jl")
    cd("../")
end
