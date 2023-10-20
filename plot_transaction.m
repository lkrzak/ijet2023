clear stairsX
clear stairsY
clear p;
stairsX(1) = 0;
stairsY(1) = tr(1,2);
for p = 1:size(tr,1)-1
    stairsX(1+p) = stairsX(p) + tr(p,1);
    stairsY(1+p) = tr(p+1,2);
end
stairsX(2+p) = stairsX(p+1) + tr(p+1,1);
stairsY(2+p) = tr(p+1,2);

stairs(stairsX, stairsY,'-o');
axis([0 stairsX(2+p)*1.1 0 max(tr(:,2))*1.1]);

