immutable InverseOperator{O,T} <: BandedBelowOperator{T}
    op::O
end

Base.inv(A::BandedBelowOperator)=InverseOperator(A)
Base.inv(A::InverseOperator)=A.op

Base.*(A::InverseOperator,f::Fun)=A.op\f