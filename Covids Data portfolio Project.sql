-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- shows Likelihood of dying if you contract COVID in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2


-- Looking at Total Cases VS Population
-- shows what percentage of population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population,
max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as InfectionPercentage
from [Portfolio Project].dbo.CovidDeaths
--where location like '%canada%'
where continent is not null
group by location, population
order by 4 desc


-- Showing Countries with Highest Death Count per Population

Select Location, population,
max(cast(total_deaths as int)) as HighestDeathsCount,
max((cast(total_deaths as int)/population))*100 as DeathsPercentage
from [Portfolio Project].dbo.CovidDeaths
--where location like '%canada%'
where continent is not null
group by location, population
order by HighestDeathsCount desc


-- Let's break things out by continent

Select location,
max(cast(total_deaths as int)) as HighestDeathsCount,
max((cast(total_deaths as int)/population))*100 as DeathsPercentage
from [Portfolio Project].dbo.CovidDeaths
--where location like '%canada%'
where continent is null
group by location
order by HighestDeathsCount desc


-- Global Numbers

select sum(new_cases) total_cases, sum(cast(new_deaths as float)) total_deaths,
sum(cast(new_deaths as float))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs Vaccinations
-- + Using a CTE 

with pop_vs_vac (coitinent, location, date, population, new_vaccinations, total_vacs_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(convert(float, vac.new_vaccinations)) 
    over (partition by dea.Location order by dea.location, dea.date) total_vacs_count
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (total_vacs_count/population)*100
from pop_vs_vac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vacs_count numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(convert(float, vac.new_vaccinations)) 
    over (partition by dea.Location order by dea.location, dea.date) total_vacs_count
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (total_vacs_count/population)*100 
from #PercentPopulationVaccinated


-- Creating a View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(convert(float, vac.new_vaccinations)) 
    over (partition by dea.Location order by dea.location, dea.date) total_vacs_count
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select* 
from PercentPopulationVaccinated
