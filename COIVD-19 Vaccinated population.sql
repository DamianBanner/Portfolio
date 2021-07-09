use PortfolioProject
select *
from coviddeaths;

select * from CovidVaccinations;

-- selecting data that i want to use

select Location, date, total_cases, new_cases, total_deaths, population	
from CovidDeaths
order by 1,2


-- looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathpercentage	
from CovidDeaths
where location like '%states%'
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of population got covid
select location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
from CovidDeaths
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestinfectionCount, max((total_cases/population))*100 as PercentPopulationinfected
from CovidDeaths
group by location, population
order by PercentPopulationinfected desc

-- showing the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as highestDeathCount
from CovidDeaths
where continent is not null
group by location
order by highestDeathCount desc

-- break things down by continent
-- showing the continents with highest deathcount per location

select continent, max(cast(total_deaths as int)) as highestDeathCount
from CovidDeaths
where continent is not null
group by continent
order by highestDeathCount desc


--global numbers
-- total cases and deaths by day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2


-- total without date

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100  as deathpercentage
from CovidDeaths
where continent is not null
order by 1,2


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingVaccinations/population*100)
from PopvsVac


-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingVaccinations/population*100)
from #PercentPopulationVaccinated


--creating views to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
