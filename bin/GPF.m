function[C,Z,obj,time]=GPF(X,beta,gamma,anchor_num)


    alpha=1;
    max_iter=15;
    view_num=size(X,2);
    [~,sample_num]=size(X{1});
    P=cell(1,view_num);
    Z=eye(sample_num);L=eye(sample_num);
    obj=zeros([1,max_iter]);
    time=0;
    K=zeros([sample_num,sample_num,view_num]);
    C=rand([sample_num,anchor_num,view_num]);
    W=zeros([sample_num,sample_num,view_num]);
    for v=1:view_num
        K(:,:,v)=X{v}'*X{v};
        C(:,:,v)=rand(sample_num,anchor_num);
        W(:,:,v)=zeros(sample_num);
    end

    for iter=1:max_iter
        Zold=Z;
        for v=1:view_num
            W(:,:,v)=L2_distance_1(C(:,:,v)',C(:,:,v)');
        end

        for v=1:view_num
            D=K(:,:,v)*C(:,:,v);
            P{v}=find_projection(D);
        end


        for v=1:view_num
            G=K(:,:,v)*P{v};
            C(:,:,v)=gpi(L,alpha*G/(2*beta));
        end



        SUMK=sum(K,3);
        SUMW=sum(W,3);

        B=(SUMK-beta/2*SUMW)/(1-beta/2+gamma)*view_num;
        parfor col=1:sample_num
            Z(:,col)=projection(B(:,col),1);
        end
        Z=(Z+Z')/2;
        LD=diag(sum(Z));
        L=LD-Z;


        obj(iter)=norm(Zold-Z,'fro')^2/norm(Zold,'fro')^2;
        if iter>2
            if obj(iter)<10^-5
                fprintf('Warning: STOP at %d: \n',iter);
                break
            end
        end
    end
end

function[Ap]=find_projection(A)
    [U,~,V]=svd(A,0);
    Ap=U*V';
    assert(norm(Ap'*Ap-eye(size(Ap,2)),'fro')<0.000000001,'wrong projection');
end

