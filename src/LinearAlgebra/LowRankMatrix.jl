

function pad!(L::LowRankMatrix,n::Integer,::Colon)
    L.U=pad(L.U,n,:)
    L
end
function pad!(L::LowRankMatrix,::Colon,m::Integer)
    L.V=pad(L.V,m,:)
    L
end
pad!(L::LowRankMatrix,n::Integer,m::Integer) = pad!(pad!(L,n,:),:,m)


for TYP in (:(ToeplitzMatrices.Hankel),)
    @eval begin
        function *(L::LowRankMatrix,A::$TYP)
            V = zeros(promote_type(eltype(L),eltype(A)),size(A,2),rank(L))
            At_mul_B!(V,A,L.V)
            LowRankMatrix(copy(L.U),V)
        end


        function *(A::$TYP,L::LowRankMatrix)
            U = zeros(promote_type(eltype(A),eltype(L)),size(A,1),rank(L))
            At_mul_B!(U,A,L.U)
            LowRankMatrix(U,copy(L.V))
        end
    end
end
