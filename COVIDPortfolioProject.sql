
-- select * 
-- from PortfolioProjects.dbo.CovidDeaths 
-- order by 3,4

-- select * from PortfolioProjects.dbo.CovidVaccinations order by 3,4

-- select Location, Date, total_cases, new_cases, total_deaths, population 
-- from PortfolioProjects.dbo.CovidDeaths 
-- order by 1,2

-- Looking at Total Cases Vs Total Deaths

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects.dbo.CovidDeaths
where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, Date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProjects.dbo.CovidDeaths
-- where Location like '%states%'
order by 1,2


-- Looking at countries with Highest infection rate compared to Population

select Location, MAX(total_cases) as HighestinfectionCount, Population, MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProjects.dbo.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- GLOBAL NUMBERS
select date ,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProjects.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
from PortfolioProjects.dbo.CovidDeaths
where continent is not null
-- Group by date
order by 1,2

select * 
from PortfolioProjects.dbo.CovidVaccinations 
order by 3,4

-- Looking at Total Population vs Vaccinations
select death.continent, death.location, death.date, death.population, Vacci.new_vaccinations
from PortfolioProjects.dbo.CovidDeaths death
Join PortfolioProjects.dbo.CovidVaccinations Vacci
on death.location = Vacci.location
and death.date = Vacci.date
where death.continent is not null
order by 2,3

select death.continent, death.location, death.date, death.population, Vacci.new_vaccinations
,SUM(CONVERT(int, Vacci.new_vaccinations)) OVER (Partition by death.Location order by death.Location, death.date)
as RollingPeopleVacccinated
from PortfolioProjects.dbo.CovidDeaths death
Join PortfolioProjects.dbo.CovidVaccinations Vacci
on death.location = Vacci.location
and death.date = Vacci.date
where death.continent is not null
order by 2,3

--using CTE
with PopulationvsVaccination (Continent, Location, Date, Population, new_vaccinations ,RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, Vacci.new_vaccinations
,SUM(CONVERT(int, Vacci.new_vaccinations)) OVER (Partition by death.Location order by death.Location, death.date)
as RollingPeopleVacccinated
from PortfolioProjects.dbo.CovidDeaths death
Join PortfolioProjects.dbo.CovidVaccinations Vacci
on death.location = Vacci.location
and death.date = Vacci.date
where death.continent is not null
-- order by 2,3
)
select *,(RollingPeopleVaccinated/Population)* 100
from PopulationvsVaccination

-- TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, Vacci.new_vaccinations
,SUM(CONVERT(int, Vacci.new_vaccinations)) OVER (Partition by death.Location order by death.Location, death.date)
as RollingPeopleVacccinated
from PortfolioProjects.dbo.CovidDeaths death
Join PortfolioProjects.dbo.CovidVaccinations Vacci
on death.location = Vacci.location
and death.date = Vacci.date
where death.continent is not null
-- order by 2,3

select *,(RollingPeopleVaccinated/Population)* 100
from #PercentPopulationVaccinated

--CREATING VIEW
create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, Vacci.new_vaccinations
,SUM(CONVERT(int, Vacci.new_vaccinations)) OVER (Partition by death.Location order by death.Location, death.date)
as RollingPeopleVacccinated
from PortfolioProjects.dbo.CovidDeaths death
Join PortfolioProjects.dbo.CovidVaccinations Vacci
on death.location = Vacci.location
and death.date = Vacci.date
where death.continent is not null
-- order by 2,3