function tracker = intialDitionary(Options)
sz_T = Options.features.sz_T;
init_pos = Options.source.init_pos;
n_D = Options.models.n_D;
initial_samples = InitialAffs(init_pos, n_D, sz_T);
tracker.current_aff = initial_samples(1,:);
img_color = Options.source.frames{1};
if ~Options.source.image
    img_color = imread(img_color);
end
n_view = Options.features.n_view;
[Dt G_V]  = OMG_extractFeatures_init(img_color,initial_samples,Options.features);
G_V_dims = zeros(n_view,1);
for i = 1:n_view
    G_V_dims (i) = G_V(i,2) - G_V(i,1) + 1;
end
Db = zeros(G_V(end),max(G_V_dims));
for i = 1:n_view
    Db(G_V(i,1):G_V(i,2),1:G_V_dims(i))= eye(G_V_dims(i));
end
tracker.Dt = Dt;
tracker.Db = Db;
tracker.G_V = G_V;
tracker.G_V_dims = G_V_dims;
