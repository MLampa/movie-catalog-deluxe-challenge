require "sinatra"
require "pg"
require 'pry'

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/actors'
end

get '/actors' do

  db_connection do |conn|
    @actors = conn.exec("SELECT name, id AS actor_id FROM actors")

  end

  erb :'actors/index'
end

get '/actors/:id' do
  @actor = nil

  db_connection do |conn|
    sql_query = "SELECT movies.id AS movie_id, actors.id AS actor_id, movies.title, actors.name AS actor_name, cast_members.character
    FROM movies
    JOIN cast_members
    ON movies.id = cast_members.movie_id
    JOIN actors
    ON actors.id = cast_members.actor_id
    WHERE actors.id = $1"

    data = [params["id"]]
    @actor = conn.exec_params(sql_query, data)

  end
  erb :'actors/show'
end

get '/movies' do

  db_connection do |conn|
    @movies = conn.exec("SELECT movies.id AS movie_id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
    FROM movies
    LEFT JOIN genres
    ON movies.genre_id = genres.id
    LEFT JOIN studios
    ON movies.studio_id = studios.id
   ")
  end

  erb :'movies/index'
end

get '/movies/:id' do
  @movies = nil
  db_connection do |conn|
    sql_query = "SELECT  movies.title, movies.id AS movie_id, actors.id AS actor_id, actors.name AS actor_name, cast_members.character AS character, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
    FROM movies
    JOIN cast_members
    ON movies.id = cast_members.movie_id
    JOIN actors
    ON actors.id = cast_members.actor_id
    JOIN genres
    ON movies.genre_id = genres.id
    JOIN studios
    ON movies.studio_id = studios.id
    WHERE movies.id = $1"

    data = [params["id"]]
    @movies = conn.exec_params(sql_query, data)

  end
  erb :'movies/show'
end
