using Test
using TimeMachine, MPI, DiffEqBase

using TimeMachine.Callbacks

MPI.Initialized() || MPI.Init()


mutable struct MyCallback
    initialized::Bool
    calls::Int
    finalized::Bool
end
MyCallback() = MyCallback(false, 0, false)

function Callbacks.initialize!(cb::MyCallback, integrator)
    cb.initialized=true
end
function Callbacks.finalize!(cb::MyCallback, integrator)
    cb.finalized=true
end
function (cb::MyCallback)(integrator)
    cb.calls += 1
end

cb1 = MyCallback()
cb2 = MyCallback()
cb3 = MyCallback()
cb4 = MyCallback()
cb5 = MyCallback()

cbs = CallbackSet(
    EveryXSimulationTime(cb1, 1/4),
    EveryXSimulationTime(cb2, 1/2, atinit=true),
    EveryXSimulationSteps(cb3, 1),
    EveryXSimulationSteps(cb4, 4,  atinit=true),
    EveryXSimulationSteps(_ -> sleep(1/32), 1),
    EveryXWallTimeSeconds(cb5, 0.49, MPI.COMM_SELF)
)

solve(const_prob, LSRKEulerMethod(), dt=1/32, callback=cbs)

@test cb1.initialized
@test cb2.initialized
@test cb3.initialized
@test cb4.initialized
@test cb5.initialized

@test cb1.calls == 4
@test cb2.calls == 3
@test cb3.calls == 32
@test cb4.calls == 9
@test cb5.calls >= 2

if isdefined(DiffEqBase, :finalize!)

    @test cb1.finalized
    @test cb2.finalized
    @test cb3.finalized
    @test cb4.finalized
    @test cb5.finalized
end
