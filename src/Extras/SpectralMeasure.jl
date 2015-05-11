using ApproxFun

#This now outputs a [-1,1] Chebyshev Fun f such that dmu(s) = f(s)(1-s^2)^{-1/2}
function spectralmeasure(a,b)
  T,K=tkoperators(a,b)

  L = T+K
  Ti=inv(T)
  m=size(K.matrix,1)
  IKin=CompactOperator(inv(full((I+K*Ti)[1:m,1:m]))-eye(m))+I
  Lin=Ti*IKin

  Fun(Lin*[1],Chebyshev)
end

function tkoperators(a,b)
    assert(length(a)-length(b)==1)
    n = length(a)
    L = Lmatrix(a,b,2n)

    T=ToeplitzOperator(vec(L[2*n,2*n-1:-1:1]),[L[n,n]])
    K = zeros(2*n,2*n)
    for i = 1:2*n
        for j = 1:i
            K[i,j] = L[i,j]-T[i,j]
        end
    end

    K = CompactOperator(K)
    T,K
end


# Finds L such that L(\Delta+Jacobi(a,b-.5))L^{-1} = \Delta, where \Delta = Toeplitz([0,.5])
function Lmatrix(a,b,N)
  # initial values
  L = zeros(N,N)
  L[1,1] = 1
  L[2,1] = -a[1]/b[1]
  L[2,2] = 1/b[1]

  n = length(a)
  # the generic case.
  for i = 3:n
      L[i,1] = (L[i-1,2]/2-a[i-1]*L[i-1,1]-b[i-2]*L[i-2,1])/b[i-1]
      for j = 2:i
          L[i,j] = (L[i-1,j+1]/2-a[i-1]*L[i-1,j]+L[i-1,j-1]/2-b[i-2]*L[i-2,j])/b[i-1]
      end
  end
  # this special case happens because b[n] = 1/2 but a[n] != 0
  L[n+1,1] = L[n,2]-2*a[n]*L[n,1]-2*b[n-1]*L[n-1,1]
  for j = 2:n+1
      L[n+1,j] = L[n,j+1]-2*a[n]*L[n,j]+L[n,j-1]-2*b[n-1]*L[n-1,j]
  end
  # this case is where b[m],b[m-1],b[m-2] = 1/2, and a[m],a[m-1] = 0, like Chebyshev
  for m = n+2:N
      L[m,1] = L[m-1,2]-L[m-2,1]
      for j = 2:m-1
        L[m,j] = L[m-1,j+1]-L[m-2,j]+L[m-1,j-1]
      end
      L[m,m] = -L[m-2,m] + L[m-1,m-1]
  end
  L
end

a = [.2,.3,-.4,.2]
b = [1,1.2,1.3]
T,K = tkoperators(a,b)

function jacobimatrix(a,b,N)
    J = zeros(N,N)
    J[1,1]=a[1]
    n=length(a)
    for i = 1:n-1
        J[i+1,i+1] = a[i+1]
        J[i,i+1] = b[i]
        J[i+1,i] = b[i]
    end
    for i = n:N-1
        J[i,i+1] = 1
        J[i+1,i] = 1
    end
    J
end

function jacobioperator(a,b)
    Δ=ToeplitzOperator([.5],[0.,.5])
    B=jacobimatrix(a,b-.5,length(a))
    Δ+CompactOperator(B)
end

joukowsky(z)=.5*(z+1./z)

function ql(T::ToeplitzOperator)
  # a(z) = q(z)l(z), where q(z)q(z*) = 1, l is analytic
  # to compute this, take logs: log a(z) = v(z) + ϕ(z), where v(z) + v(z*) = 0, ϕ is analytic
  # then take q = exp(v), l = exp(ϕ)

  # This function is the wrong way around to usual because we want lower triangulars to give analytic symbols
  # In future if T is symmetric then we should be using CosSpace
  a = Fun(ApproxFun.interlace([T.nonnegative[1];T.negative],T.nonnegative[2:end]),Laurent(Circle()))
  la=log(a)

  # The ideal implementation uses SinSpace:
  # v=Fun(2im*la.coefficients[2:2:end],SinSpace(Circle()))

  v=Fun(ApproxFun.interlace([0.;-la.coefficients[2:2:end]],la.coefficients[2:2:end]),Laurent(Circle()))
  q=exp(v)

  Qtranspose = ToeplitzOperator(q)
  ToeplitzOperator(Qtranspose.nonnegative[2:end],[Qtranspose.nonnegative[1];Qtranspose.negative])

  ϕ=la-v
  l=exp(ϕ)
  Ltranspose = ToeplitzOperator(l)
  ToeplitzOperator(Ltranspose.nonnegative[2:end],[Ltranspose.nonnegative[1]])

end

T = ToeplitzOperator([2.,.5])
T[1:10,1:10]
a = Fun(ApproxFun.interlace([T.nonnegative[1];T.negative],T.nonnegative[2:end]),Laurent(Circle()))
  la=log(a)
v=Fun(ApproxFun.interlace([0.;-la.coefficients[2:2:end]],la.coefficients[2:2:end]),Laurent(Circle()))
  q=exp(v)
Qtranspose = ToeplitzOperator(q)
  Q = ToeplitzOperator(Qtranspose.nonnegative[2:end],[Qtranspose.nonnegative[1];Qtranspose.negative])

(Qtranspose*Q-I)[2:20,2:20]|>full|>norm
(Q*Qtranspose-I)[9:100,9:100]|>full|>norm
