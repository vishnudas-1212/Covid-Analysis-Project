--select *
--from [Covid Project].dbo.covidDeaths
--where continent is not null
--order by 3,4

--select *
--from [Covid Project].dbo.covidvaccinations
--order by 3,4

select location, date, total_cases,new_cases,total_deaths,population
from [Covid Project].dbo.covidDeaths
order by 1,2

select location, date, total_cases,total_deaths,(total_cases/total_deaths)*100 as Deathpercentage
from [Covid Project].dbo.covidDeaths
where location like '%states%'
order by 1,2


-- Looking at Total cases vs population
-- Shows what percentage of population got covid in united states

select location, date, total_cases,Population,(total_cases/population)*100 as Populationpercentage
from [Covid Project].dbo.covidDeaths
where location like '%states%'
order by 1,2

-- Shows what percentage of population got covid in world
select location, date, total_cases,Population,(total_cases/population)*100 as Populationpercentage
from [Covid Project].dbo.covidDeaths
--where location like '%states%'
order by 1,2


-- Looking at countries with Highest Infection rate compared to population

select location,population, max(total_cases) as HighestInfectioncount, max((total_cases/population))*100
as percentpopulationInfected
from [Covid Project].dbo.covidDeaths
group by location,Population
order by percentpopulationInfected desc

select location,population, max(total_cases) as HighestInfectioncount, max((total_cases/population))*100
as percentpopulationInfected
from [Covid Project].dbo.covidDeaths
group by location,Population
order by percentpopulationInfected desc


--Showing countries with highest death count per population

select location,Max(cast(total_deaths as Int)) as death_count
from [Covid Project].dbo.covidDeaths
where continent is not null
group by location
order by death_count desc

--Showing Continents with highest death count per population

select continent,Max(cast(total_deaths as Int)) as death_count
from [Covid Project].dbo.covidDeaths
where continent is not null
group by continent
order by death_count desc

select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Covid Project].dbo.covidDeaths
where continent is not null
order by 1,2

select * from [Covid Project]..CovidDeaths da
join 
[Covid Project]..CovidVaccinations va
on da.location=va.location
and da.date=va.date

-- looking at total population vs vaccination

select count(total_vaccinations)/count(population) *100 as Vaccinated_Percentage from [Covid Project]..CovidDeaths da
join 
[Covid Project]..CovidVaccinations va
on da.location=va.location
and da.date=va.date

DECLARE @DecimalValue DECIMAL(4,2)


with popvsvac (continent,Location,Date,Population,New_vaccinations,Rolling_people_vaccinated)
as
(
select da.continent,da.location,da.date,da.population,va.new_vaccinations,
sum(cast(va.new_vaccinations as numeric(15,2))) over(partition by da.location order by da.location,da.date)
as Rolling_people_vaccinated
from [Covid Project]..CovidDeaths da
join 
[Covid Project]..CovidVaccinations va
on da.location=va.location
and da.date=va.date
where da.continent is not null
--order by 1,2
)

select *,(Rolling_people_vaccinated/population)*100 as Percentage_of_vaccinated
from popvsvac

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
Location varchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric,
)
insert into #percentagepopulationvaccinated
select da.continent,da.location,da.date,da.population,va.new_vaccinations,
sum(cast(va.new_vaccinations as numeric(15,2))) over(partition by da.location order by da.location,da.date)
as Rolling_people_vaccinated
from [Covid Project]..CovidDeaths da
join 
[Covid Project]..CovidVaccinations va
on da.location=va.location
and da.date=va.date
--where da.continent is not null
--order by 1,2


select *,(Rolling_people_vaccinated/population)*100 as Percentage_of_vaccinated
from #percentagepopulationvaccinated

--Creating a view for the later purpose

create view percentagepopulationvaccinated1 as 
select da.continent,da.location,da.date,da.population,va.new_vaccinations,
sum(cast(va.new_vaccinations as numeric(15,2))) over(partition by da.location order by da.location,da.date)
as Rolling_people_vaccinated
from [Covid Project]..CovidDeaths da
join 
[Covid Project]..CovidVaccinations va
on da.location=va.location
and da.date=va.date
where da.continent is not null
--order by 1,2
