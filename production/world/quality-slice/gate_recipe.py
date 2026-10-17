"""Original pine-charter crown and asymmetrical carved pier insets.
Local Roblox Y-up coords; extends reviewed arch art only, never collision.
"""
def make_gate():
    m=dict(vertices=[],triangles=[],faceColors=[],colors=[
        [.49,.51,.44],[.34,.38,.32],[.20,.32,.27],
        [.63,.56,.36],[.76,.68,.44],[.39,.45,.34]])
    def tri(a,b,c,color):
        n=len(m['vertices']);m['vertices'].extend([a,b,c]);m['triangles'].append([n,n+1,n+2]);m['faceColors'].append(color)
    def plaque(outline,front,back,face,side):
        # Outline counterclockwise in XY; front faces toward +Z/arrival.
        cx=sum(x for x,y in outline)/len(outline);cy=sum(y for x,y in outline)/len(outline)
        for i,(x,y) in enumerate(outline):
            xx,yy=outline[(i+1)%len(outline)]
            tri((cx,cy,front),(x,y,front),(xx,yy,front),face)
            tri((cx,cy,back),(xx,yy,back),(x,y,back),side)
            tri((x,y,back),(xx,yy,back),(xx,yy,front),side)
            tri((x,y,back),(xx,yy,front),(x,y,front),side)
    # Faceted leaf-shaped keystone with a deliberate off-center chipped shoulder.
    outline=[(0,22.3),(3.2,23.7),(2.65,26.1),(1.5,26.5),(0,28.5),(-2.9,26.0),(-3.2,23.7)]
    plaque(outline,1.61,.95,1,2)
    inner=[(x*.81,25.1+(y-25.1)*.79) for x,y in outline]
    plaque(inner,1.68,1.62,3,2)
    # Original three-tier pine shares the established arrival charter language.
    plaque([(-.12,23.5),(.12,23.5),(.12,26.5),(-.12,26.5)],1.725,1.67,4,4)
    for y,w,h in [(24.0,1.45,1.3),(24.9,1.1,1.2),(25.75,.7,1.15)]:
        plaque([(-w,y),(w,y),(0,y+h)],1.735,1.67,5,4)
    # Narrow offset crown deliberately preserves the sampled combat sightlines.
    m['vertices']=[(3+x*.5,y,z) for x,y,z in m['vertices']]
    # Paired reliefs remain strictly on the original solid piers. Left is a
    # complete charter carving; right has a chipped top and a shorter leaf sprig.
    for sign in (-1,1):
        x=sign*8.95
        top=12.0 if sign<0 else 10.5
        outline=[(x-.75,4.1),(x+.75,4.1),(x+.75,top-.45),(x+.2,top),(x-.75,top-.2)]
        plaque(outline,1.60,1.20,1,2)
        inset=[(x+(xx-x)*.72,8+(yy-8)*.91) for xx,yy in outline]
        plaque(inset,1.66,1.60,3,2)
        plaque([(x-.07,5),(x+.07,5),(x+.07,top-.8),(x-.07,top-.8)],1.705,1.65,4,4)
        for i in range(3 if sign<0 else 2):
            y=6+i*1.6
            plaque([(x,y),(x+.48,y+.35),(x,y+1),(x-.48,y+.35)],1.73,1.65,5,4)
    assert len(m['triangles'])<=400
    return m
