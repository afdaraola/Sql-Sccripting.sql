
select *   from bricks;
--Oracle Json functions

--1. json_object
select json_object('shape' value shape) as json_obj from bricks;

--1. json_objectagg
select json_objectagg('shape' value shape) as json_objagg from bricks;

--json array
select JSON_ARRAY(shape) as json_arry from bricks;

--json arayagg
select JSON_ARRAYAGG(shape) as json_arryagg from bricks;


--use case 

select JSON_OBJECTagg(shape value json_objectagg('shape' value shape)) as  shape_jason from bricks 
group by shape;



select JSON_OBJECTagg(colour value json_array( colour)) as  shape_array from bricks 
group by colour;



select json_arrayagg(json_arrayagg( colour)) as  shape_array from bricks 
group by colour

