/*
Covid 19 Data Exploration 

*/

--select *
--from PortfolioProject1..CovidDeaths$
--order by 3,4

--select *
--from PortfolioProject1..CovidVaccinations$
--order by 3,4

--select data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject1..CovidDeaths$
order by 1,2

--looking at total_cases vs total_deaths
--shows likelihood of dying if you contract covid in your country 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths$
where location like '%states%'
order by 1,2 

--looking at the total_casrs vs population 
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
order by 1,2 

--looking at countries with highest infection rate compared to population

select location,max(total_cases) as HighestInfectionCount,population,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
group by population,location
order by PercentPopulationInfected desc

--lets break things down by continent
--showing countries with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing the continents with the highest deat count   
select location, max(total_deaths ) as TotalDeathCount
from PortfolioProject1..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--global numbers 

select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths$ 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2
;
--looking at total population vs vaccinations
--use cte
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
as PercentageRollingPeopleVaccinated
From PopvsVac

--temp table 
drop table if exists #PercentPoplulationVaccinated 
create table #PercentPoplulationVaccinated 
(
 continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
	)
insert into #PercentPoplulationVaccinated 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location
order by dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
as PercentageRollingPeopleVaccinated
From #PercentPoplulationVaccinated 

--creating view to store data for later visualisations 

-- CREATE VIEW statement is the first statement
 create view #PercentPoplulationVaccinated as 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location
order by dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 from PortfolioProject1..CovidDeaths$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
 select *
 from #PercentPoplulationVaccinated 
