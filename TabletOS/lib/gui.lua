local a=require("component")local b=a.gpu;local c=require("unicode")local d=require("event")local e={}function e.centerText(f,g,h)local i=f-math.floor(c.len(h)/2)b.set(i,g,h)end;function e.setColors(j,k)return b.setBackground(j),b.setForeground(k)end;function e.drawProgressBar(f,g,l,m,n,o,p)m=m or 0x000000;n=n or 0xFFFFFF;o=o or 0;p=p or 100;local q=1;local r=l/p;local s,t=math.modf(r*o)local u;if t>0.5 then u=s+1 else u=s end;local v=b.setBackground(m)b.fill(f,g,l,1," ")b.setBackground(n)b.fill(f,g,u,1," ")b.setBackground(v)end;function e.animatedProgressBar(f,g,l,m,n,o,p,w)m=m or 0x000000;n=n or 0xFFFFFF;o=o or 0;p=p or 100;local q=1;local r=l/p;local s,t=math.modf(r*o)local u;if t>0.5 then u=s+1 else u=s end;local x=l/p;local y,z=math.modf(x*w)local A;if z>0.5 then A=y+1 else A=y end;local v=b.setBackground(m)b.fill(f,g,l,1," ")b.setBackground(n)for B=A,u do b.fill(f,g,B,1," ")os.sleep(0.05)end;b.setBackground(v)end;function e.clickedAtArea(f,g,C,D,E,F)if E>=f and E<=C and F>=g and F<=D then return true end;return false end;function e.drawButton(f,g,l,q,h,G,H)local v,I=e.setColors(G,H)b.fill(f,g,l,q," ")local J=f+math.floor(l/2)local K=g+math.floor(q/2)e.centerText(J,K,h)e.setColors(v,I)local function L(E,F)local f,g,l,q=f,g,l,q;local C=f+l;local D=g+q;if E>=f and E<=C and F>=g and F<=D then return true end;return false end;return L end;return e
