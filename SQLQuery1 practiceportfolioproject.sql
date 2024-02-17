select * from portfolioproject..Coviddeath$;

select location, date, total_cases,new_cases,total_deaths,population
from portfolioproject..Coviddeath$
order by 1,2


--looking at total cases vs total deaths
select location, date,total_cases,total_deaths,(total_deaths/total_cases )*100
from portfolioproject..Coviddeath$
order by 1,2


-- looking at total cases vs population
--show what percentage population got in covid
select Location, date, population, total_cases,(total_cases/population)*100 as Deathpercentage
from portfolioproject..Coviddeath$
--where location like '%states%'
order by 1,2

--looking at countries with heighest infection rate compared to population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from portfolioproject..Coviddeath$
Group by location, population
order by PercentagePopulationInfected desc

-- showing countries with Heighest Death Count as per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..Coviddeath$
--where continent is not null
Group by location
order by TotalDeathCount desc

-- lets break things down by continent
--showing continent with the heighest deaths count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..Coviddeath$
where continent is  not null
Group by continent
--where continent is null
--Group by  location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from portfolioproject..Coviddeath$
where continent is not null
--Group by date
order by 1,2

-- JOINS 
select * from portfolioproject..Covidvaccination$

select *
from portfolioproject..Coviddeath$ dea
join portfolioproject..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location  order by dea.location,dea.date) as Rollingpeoplevaccinated 
from portfolioproject..Coviddeath$ dea
join portfolioproject..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (continent, location, date, population, new_vaccination, Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location  order by dea.location,dea.date) as Rollingpeoplevaccinated 
from portfolioproject..Coviddeath$ dea
join portfolioproject..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rollingpeoplevaccinated/population)*100
from PopvsVac




-- Temp Table 
  DROP table if exists #PercentPopulationVaccinated
  create table #PercentPopulationVaccinated
  (
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  Rollingpeoplevaccinated numeric
  )
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location  order by dea.location,dea.date) as Rollingpeoplevaccinated 
from portfolioproject..Coviddeath$ dea
join portfolioproject..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * , (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

-- Create View to store data for later visualizations

create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location  order by dea.location,dea.date) as Rollingpeoplevaccinated 
from portfolioproject..Coviddeath$ dea
join portfolioproject..Covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
