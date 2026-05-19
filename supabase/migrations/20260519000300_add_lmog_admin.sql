insert into app_admins (email, nombre)
values ('lmog240@gmail.com', 'Admin')
on conflict (email) do update
set activo = true,
    nombre = coalesce(app_admins.nombre, excluded.nombre);
