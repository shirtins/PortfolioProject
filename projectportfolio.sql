Select * 
From PortfolioProject..CovidDeaths
where continent is not null;

--Select * 
--From PortfolioProject..CovidVaccinations;

-- Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Looking at Total cases vs Total Deaths
-- This shows the likelihood of dying if you atract covid in your country.
Select Location, date, total_cases,total_deaths, 
(total_deaths/total_cases) * 100 as death_per_case
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2;

-- Lookingat the total cases vs the population
-- shows what percentage of population got covid
Select Location, date, total_cases,population, 
(total_cases/population) * 100 as cases_per_pop
from PortfolioProject..CovidDeaths
where location like '%Nigeria%' or location like '%states%' and continent is not null
order by 1,2;

-- looking at countries with highest infection rate compared with population
Select Location, Population,
Max(total_cases) as Highestcount,
Max(total_cases/population) *100 as PercentPopInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location,population
order by PercentPopInfected desc;

-- Showing the countries with the highest death count by population
Select Location, Population,
Max(cast(total_deaths as int)) as Highestdeathcount,
Max(cast(total_deaths as int)/population) *100 as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location,population
order by Highestdeathcount desc;

-- Let's break it down by continent

Select location, Max(Population) as Population,
Max(cast(total_deaths as int)) as Highestdeathcount
from PortfolioProject..CovidDeaths
where continent is null
Group by location
order by Highestdeathcount desc;

--Global Numbers per day
Select date, SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2;

--Global Numbers
Select SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2;
 

 -- Total Population vs vaccinations worldwide

Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER(partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated


From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Use CTE
With PopvsVac(Continent, Location, Date, Population,New_Vaccinations,
RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER(partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100  
from PopvsVac;

--Using a temporary table
DROP TABLE IF EXISTS PopPercVaccinated
CREATE TABLE PopPercVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population int,
New_Vaccinations int,
RollingPeopleVaccinated int)

INSERT INTO PopPercVaccinated

Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER(partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100  
from PopPercVaccinated;

--Creating view to stay data for data Visualizations

drop view if exists PercentPopulationVaccinated

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) 
OVER(partition by dea.location 
	order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated;


