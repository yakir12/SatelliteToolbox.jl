Orbit propagators
=================

```@meta
CurrentModule = SatelliteToolbox
DocTestSetup = quote
    using SatelliteToolbox
end
```

Currently, there are four orbit propagators available: **Two Body**, **J2**,
**J4** and **SGP4**.  All coded in Julia (no external libraries required).

## Two Body

This algorithm assumes a Keplerian orbit, *i.e.* considers that the Earth is
spherical with the gravitational force computed by Newton's laws.

## J2

This algorithm considers the perturbation terms up to `J2` and the drag effects.
The implementation available here was adapted from [1].

## J4

This algorithm considers the perturbation terms `J2`, `J2²`, and `J4` and the
drag effects. The implementation available here was adapted from [1].

## SGP4

The SGP4 algorithm here was based on [2,3]. It contains the deep space support
that is automatically selected based on the input orbit. Hence, technically, it
is the SPG4/SDP4 algorithm, which will be called just SGP4 here.

## Initialization

All the propagators need to be initialized first using the API function
`init_orbit_propagator`. The functions signature for each algorithm can be seen
as follows.

### Initialization of Two body, J2, and J4

The orbit propagators **two body**, **J2**, and **J4** can be initialized using
three different methods.

```julia
function init_orbit_propagator(T, epoch::Number, a_0::Number, e_0::Number, i_0::Number, Ω_0::Number, ω_0::Number, f_0::Number)
```

where:

* `T` is the type of the orbit propagator (`Val(:twobody)` for **Two Body**,
  `Val(:J2)` for **J2**, and `Val(:J4)` for **J4**).
* `epoch`: Initial orbit epoch \[Julian Day].
* `a_0`: Initial semi-major axis \[m].
* `e_0`: Initial eccentricity.
* `i_0`: Initial inclination \[rad].
* `Ω_0`: Initial right ascension of the ascending node \[rad].
* `ω_0`: Initial argument of perigee \[rad].
* `f_0`: Initial true anomaly \[rad].

!!! note

    The inputs are the mean orbital elements.

```julia
function init_orbit_propagator(T, orb_0::Orbit)
```

where:

* `T` is the type of the orbit propagator (`Val(:twobody)` for **Two Body**,
  `Val(:J2)` for **J2**, and `Val(:J4)` for **J4**).
* `orb_0`: Initial orbital elements (see `Orbit`).

```julia
function init_orbit_propagator(T, tle::TLE)
```

where:

* `T` is the type of the orbit propagator (`Val(:twobody)` for **Two Body**,
  `Val(:J2)` for **J2**, and `Val(:J4)` for **J4**).
* `tle`: TLE that will be used to initialize the propagator (see [TLE](@ref)).

There are some optional parameters that depend on the orbit propagator type that
can be used to customize the algorithm. Those options are listed as follows:

**Two Body**

* `μ`: Standard gravitational parameter of the central body \[m³/s²]
  (**Default** = `m0`).

**J2 Orbit Propagator**

* `dn_o2`: First time derivative of mean motion divided by 2 \[rad/s²]
  (**Default** = 0).
* `ddn_o6`: Second time derivative of mean motion divided by 6 \[rad/s³]
  (**Default** = 0).
* `j2_gc`: J2 orbit propagator gravitational constants (see `J2_GravCte`)
  (**Default** = `j2_gc_egm08`).

!!! warning

    The two first options are not available when the TLE is used because this
    information is provided by the TLE.

**J4 Orbit Propagator**

* `dn_o2`: First time derivative of mean motion divided by 2 \[rad/s²]
  (**Default** = 0).
* `ddn_o6`: Second time derivative of mean motion divided by 6 \[rad/s³]
  (**Default** = 0).
* `j4_gc`: J4 orbit propagator gravitational constants (see `J4_GravCte`)
  (**Default** = `j4_gc_egm08`).

!!! warning

    The two first options are not available when the TLE is used because this
    information is provided by the TLE.

### Initialization using the angular velocity

If the orbit is defined in terms of the angular velocity (mean motion) instead
of the semi-major axis, then it is possible to use the function `angvel_to_a` to
convert:

```julia
function angvel_to_a(n::Number, e::Number, i::Number, pert::Symbol = :J2)
```

It computes the semi-major axis that will provide an angular velocity `n`
[rad/s] in an orbit with eccentricity `e` and inclination `i` [rad], using the
perturbation terms specified by the symbol `pert`.

Notice that the angular velocity `n` is related to the nodal period, *i.e.* the
time between two consecutive passages by the ascending node.

`pert` can be:

* `:J0`: Consider a Keplerian orbit.
* `:J2`: Consider the perturbation terms up to J2.
* `:J4`: Consider the perturbation terms J2, J4, and J2².

If `pert` is omitted, then it defaults to `:J2`.

### Initialization of SGP4

The SGP4/SDP4 propagator is meant to be used together with a TLE. Hence, the
initialization using user-defined orbital elements is not available through the
API. If this is really required, then the user must access the low-level
function `sgp4_init`.

The API function to initialize the SGP4 using a TLE is:

```julia
function init_orbit_propagator(T, tle::TLE, sgp4_gc::SGP4_GravCte = sgp4_gc_wgs84)
```

where:

* `T` must be `Val(:sgp4)`;
* `tle`: TLE that will be used to initialize the propagator (see [TLE](@ref)).
* `sgp4_gc`: Gravitational constants (see `SGP4_GravCte`) (**Default** =
  `sgp4_gc_wgs84`).

## Propagation

After the orbit propagator is initialized, the orbit can be propagated by the
API functions `propagate!`, `propagate_to_epoch!`, and `step!`.

The function `propagate!` has two signature. The first one is

```julia
function propagate!(orbp, t::Number) where T
```

in which the orbit will be propagated by `t` \[s] **from the orbit epoch**,
which is defined in the initialization and is never changed. This function
returns a tuple with three values:

* The mean Keplerian elements represented in the inertial reference frame
  encapsulated in an instance of the structure `Orbit` \[SI units].
* The position vector represented in the inertial reference frame \[m].
* The velocity vector represented in the inertial reference frame \[m].

The second signature of `propagate!` is:

```julia
function propagate!(orbp, t::AbstractVector) where T
```

where the orbit will be propagated for every value in the vector `t` \[s], which
is a number of seconds **from the orbit epoch**. In this case, an array of
tuples with be returned with each element equivalent to that described for the
first case.

The function `propagate_to_epoch!` also have two signatures similar to
`propagate!`:

```julia
function propagate_to_epoch!(orbp, JD::Number) where T
function propagate_to_epoch!(orbp, JD::AbstractVector) where T
```

It also returns the same information. However, the input argument `JD` is an
epoch \[Julian Day] to which the orbit will be propagated instead of the number
of seconds from the orbit epoch.

!!! warning

    The conversion from Julian Day to seconds that `propagate_to_epoch!` must
    perform can introduce numerical errors.

The `step!` function has the following signature:

```julia
function step!(orbp, Δt::Number)
```

where the orbit is propagated by `Δt` \[s] from the last propagation instant.
This function returns the same information of the first signature of
`propagate!` method.

In all cases, the structure `orbp` is modified by updating the orbit elements
related to the last propagation instant.

!!! note

    All the algorithms can be used to propagate the orbit forward or backward in
    time.

### Reference systems

The inertial reference system in which the propagated values are represented
depends on the reference system used to represent the input data. For TLE
representation, it is very common to use the TEME (True Equator, Mean Equinox)
frame. For more information, see [1].

## Examples

```jldoctest
julia> orbp = init_orbit_propagator(Val(:twobody), 0.0, 7130982.0, 0.001111, 98.405 * pi / 180, pi / 2, 0.0, 0.0);

julia> r, v = propagate!(orbp, collect(0:3:24)*60*60);

julia> r
9-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [4.361615995545557e-10, 7.123059478998e6, 0.0]
 [-987245.0339067932, 2.2795965650559943e6, -6.681575536564488e6]
 [-634570.3708145625, -5.6651018878703015e6, -4.294708730095805e6]
 [577611.4580468672, -5.943853473864736e6, 3.909216511784105e6]
 [1.0074912863924972e6, 1.8203277350500443e6, 6.818600146129005e6]
 [70133.24341579647, 7.106899204003144e6, 474654.76899136906]
 [-962529.3359925373, 2.7285451480913754e6, -6.514302167865425e6]
 [-688667.0923815856, -5.36079828379197e6, -4.660829924952772e6]
 [518047.6024024392, -6.195799233949873e6, 3.506094300915793e6]
```

```jldoctest
julia> orbp = init_orbit_propagator(Val(:J2), KeplerianElements(0.0, 7130982.0, 0.001111, 98.405 * pi / 180, pi / 2, 0.0, 0.0));

julia> r, v = propagate!(orbp, collect(0:3:24) * 60 * 60);

julia> r
9-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [4.361615995545557e-10, 7.123059478998e6, 0.0]
 [-996350.5627452108, 2.186373157247237e6, -6.711368000333959e6]
 [-587227.7525506096, -5.782378228281175e6, -4.142557925272834e6]
 [649426.5668814591, -5.775582427101443e6, 4.1430161225754153e6]
 [972827.4418151112, 2.196925098537513e6, 6.711636962147706e6]
 [-76509.36508562126, 7.122652836574904e6, 475.61934682240826]
 [-1.0197591007931489e6, 2.1755856272240356e6, -6.711096628505176e6]
 [-524958.6813354684, -5.788492655475164e6, -4.1421039190142583e6]
 [711547.4810490764, -5.768106186767626e6, 4.143478050495974e6]
```

```jldoctest
julia> orbp = init_orbit_propagator(Val(:J2), KeplerianElements(date_to_jd(1986, 6, 19, 0, 0, 0), 7130982.0, 0.001111, 98.405 * pi / 180, pi / 2, 0.0, 0.0));

julia> r, v = propagate_to_epoch!(orbp, date_to_jd(1986, 6, 19, 0, 0, 0) .+ collect(0:3:24) / 24);

julia> r
9-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [4.361615995545557e-10, 7.123059478998e6, 0.0]
 [-996350.5627452108, 2.186373157247237e6, -6.711368000333959e6]
 [-587227.7525506096, -5.782378228281175e6, -4.142557925272834e6]
 [649426.5668814591, -5.775582427101443e6, 4.1430161225754153e6]
 [972827.4418151112, 2.196925098537513e6, 6.711636962147706e6]
 [-76509.36508562126, 7.122652836574904e6, 475.61934682240826]
 [-1.0197591007931489e6, 2.1755856272240356e6, -6.711096628505176e6]
 [-524958.6813354684, -5.788492655475164e6, -4.1421039190142583e6]
 [711547.4810490764, -5.768106186767626e6, 4.143478050495974e6]
```

```jldoctest
julia> orbp = init_orbit_propagator(Val(:J4), KeplerianElements(date_to_jd(1986, 6, 19, 0, 0, 0), 7130982.0, 0.001111, 98.405 * pi / 180, pi / 2, 0.0, 0.0));

julia> r, v = propagate!(orbp, (0:3:24) * 60 * 60);

julia> r
9-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [4.361615995545557e-10, 7.123059478998e6, 0.0]
 [-996366.9594234177, 2.1861582928190185e6, -6.711435734685331e6]
 [-587137.7898110648, -5.7826428097349685e6, -4.1422016962297964e6]
 [649557.2207988158, -5.775184062488014e6, 4.143550414292531e6]
 [972752.5982241486, 2.1977837698636954e6, 6.711365970393662e6]
 [-76783.52152808056, 7.1226498462156085e6, -625.3752709346008]
 [-1.0198435837396844e6, 2.174295411570012e6, -6.711502954871595e6]
 [-524633.841231651, -5.7894151019522315e6, -4.1408569967521494e6]
 [711884.4066346248, -5.767040023322984e6, 4.144902689785466e6]
```

```jldoctest
julia> tle_scd1 = tle"""
       SCD 1
       1 22490U 93009B   18350.91204528  .00000219  00000-0  10201-4 0  9996
       2 22490  24.9683 170.6788 0043029 357.3326 117.9323 14.44539175364603
       """[1];

julia> orbp = init_orbit_propagator(Val(:sgp4), tle_scd1);

julia> r, v = propagate!(orbp, (0:3:24) * 60 * 60);

julia> r
9-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [2.1104012562923166e6, -6.248944717841756e6, 2.7103754647550117e6]
 [-5.592457608056556e6, -3.7813257981715053e6, 2.1882968787571643e6]
 [-5.988375857808983e6, 3.627483705445919e6, -1.1327315536731675e6]
 [1.4405613907279489e6, 6.296033411211332e6, -3.0047273909310466e6]
 [7.026149940376372e6, 791501.9859623271, -1.061727896730936e6]
 [3.6069983933267347e6, -5.743279083559109e6, 2.21988653760847e6]
 [-4.430433261051032e6, -4.853641397034228e6, 2.6886290511943335e6]
 [-6.675541341088373e6, 2.372196988700215e6, -279066.08984961873]
 [-193293.3502548483, 6.501272877734009e6, -2.8915511460724827e6]

julia> v
9-element Vector{StaticArraysCore.SVector{3, Float64}}:
 [7129.19085352138, 1784.0696855845256, -1358.3238197147184]
 [4573.3147340566975, -5547.0437916909905, 2171.2458526391238]
 [-3969.352987692075, -5663.638822765204, 2940.09359907522]
 [-7305.141378585876, 1611.5624355458967, -49.362957814204904]
 [-1211.7826922676047, 6739.965820219686, -2945.926548674715]
 [6417.953384292589, 3175.7563180703937, -2122.04199768743]
 [5799.586839459342, -4551.632088286132, 1407.446888081471]
 [-2391.636997068708, -6387.691108730701, 3161.6577154337137]
 [-7435.439550407853, 128.80933740830324, 866.5999572489661]

julia> orbp = init_orbit_propagator(Val(:sgp4), tle_scd1);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r, v = step!(orbp, 3*60*60);

julia> r
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 -193293.3502548483
       6.501272877734009e6
      -2.8915511460724827e6

julia> v
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 -7435.439550407853
   128.80933740830324
   866.5999572489661
```

## Low level access

All propagators can be accessed by low-level functions. This allows the user to
have more control about the algorithm and also to reduce the overhead related to
the API functions. If such optimization is necessary, see the functions inside
the directory `./src/orbit/propagators`.

## References

[1] **Vallado, D. A., McClain, W. D (2013).** *Fundamentals of astrodynamics and
applications*. Hawthorne, CA: Microcosm Press.

[2] **Hoots, F. R., Roehrich, R. L (1980).** *Models for Propagation of NORAD
Elements Set*. Spacetrack Report No. 3.

[3] **Vallado, D. A., Crawford, P., Hujsak, R., Kelso, T. S (2006).**
*Revisiting Spacetrack Report #3: Rev1*. AIAA.

