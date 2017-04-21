local a=require("component")local b=a.gpu;local c=require("unicode")local d=require("event")local e=require("ECSAPI")local f={}function f.centerText(g,h,i)local j=g-math.floor(c.len(i)/2)b.set(j,h,i)end;function f.setColors(k,l)return b.setBackground(k),b.setForeground(l)end;function f.drawProgressBar(g,h,m,n,o,p,q)n=n or 0x000000;o=o or 0xFFFFFF;p=p or 0;q=q or 100;local r=1;local s=m/q;local t,u=math.modf(s*p)local v;if u>0.5 then v=t+1 else v=t end;local w=b.setBackground(n)b.fill(g,h,m,1," ")b.setBackground(o)b.fill(g,h,v,1," ")b.setBackground(w)end;function f.animatedProgressBar(g,h,m,n,o,p,q,x)n=n or 0x000000;o=o or 0xFFFFFF;p=p or 0;q=q or 100;local r=1;local s=m/q;local t,u=math.modf(s*p)local v;if u>0.5 then v=t+1 else v=t end;local y=m/q;local z,A=math.modf(y*x)local B;if A>0.5 then B=z+1 else B=z end;local w=b.setBackground(n)b.fill(g,h,m,1," ")b.setBackground(o)for C=B,v do b.fill(g,h,C,1," ")os.sleep(0.05)end;b.setBackground(w)end;function f.clickedAtArea(g,h,D,E,F,G)if F>=g and F<=D and G>=h and G<=E then return true end;return false end;function f.drawButton(g,h,m,r,i,H,I)local w,J=f.setColors(H,I)b.fill(g,h,m,r," ")local K=g+math.floor(m/2)-1;local L=h+math.floor(r/2)-1;f.centerText(K,L,i)f.setColors(w,J)local function M(F,G)local g,h,m,r=g,h,m,r;local D=g+m;local E=h+r;if F>=g and F<=D and G>=h and G<=E then return true end;return false end;return M end;return f
