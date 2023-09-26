/*									COVID 19 DATA EXPLORATION

THIS IS A DATA EXPLORATION PROJECT ON COVID-19 DEATHS IN NIGERIA AND AFRICA BETWEEN JAN, 2020AND APRIL 2021
Skills used: Joins, Converting Data Types, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views,
*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--selecting data we are going to be using

select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--looking at total_cases vs total_deaths 
 --Shows likelihood of dying if you contract covid in nigeria
select location,date, total_cases,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%nigeria%'
order by 1,2
 
 --looking at total_cases vs population
 --show the percentage of population has gotten covid
 select location, date,population, total_cases, (total_cases/population)*100 as PercentInfectedwithCovid
 from PortfolioProject..CovidDeaths
 where location like '%Nigeria%'
 order by 1,2

 -- Countries with Highest Infection Rate compared to Population

 select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100
 as PercentPopulationInfected
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location,population
 order by PercentPopulationInfected desc 

 

 --countries with highest death count rate per population
 
 select location, max(cast (total_deaths as int)) as TotalDeathCount, max((total_deaths/total_cases))*100 as PercentDeath
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location
 order by TotalDeathCount desc 


 

-- BREAKING THINGS DOWN BY CONTINENT

--continents with the highest infection rate

 select continent, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100
 as PercentPopulationInfectedcont
 from PortfolioProject..CovidDeaths
 group by continent
 order by PercentPopulationInfectedcont desc

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int))as TotalDeathCount 
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent
 order by TotalDeathCount desc 

 select location, max(cast(total_deaths as int))as TotalDeathCount 
 from PortfolioProject..CovidDeaths
 where continent is null
 group by location
 order by TotalDeathCount desc 



 --GLOBAL NUMBERS (getting insight accross the world)

   select --date,
   sum(new_cases) as total_cases, sum(convert(int,new_deaths)) as TotalDeaths,
   sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 --group by date
 order by 1,2

 
-- Total Population vs Vaccinations
-- what Percentage of Population has recieved at least one Covid Vaccine

 select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated,
 --, (RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths as dea
 join
 PortfolioProject..CovidVaccinations as vac
 on dea.location =vac.location
 and dea.date =vac.date
  where dea.continent is not null
 order by 2,3

 ---- Using CTE to perform Calculation on Partition By in previous query
 with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as(

 select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths as dea
 join
 PortfolioProject..CovidVaccinations as vac
 on dea.location =vac.location
 and dea.date =vac.date
  where dea.continent is not null
 --order by 2,3

 )select*, (RollingPeopleVaccinated/population)*100
 from PopvsVac


 -- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 insert into #PercentPopulationVaccinated
  select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths as dea
 join
 PortfolioProject..CovidVaccinations as vac
 on dea.location =vac.location
 and dea.date =vac.date
 -- where dea.continent is not null
 --order by 2,3

 select*, (RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated



-- CREATING VIEWS TO STORE DATA FOR VISUALIZATION LATER ON

--view for Countries with Highest Infection Rate compared to Population
create view HighestInfectionCount as
 select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100
 as PercentPopulationInfected
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location,population
 --order by PercentPopulationInfected desc 

 

 -- Views for countries with highest death count rate per population
 create view TotalDeath as
 select location, max(cast (total_deaths as int)) as TotalDeathCount, max((total_deaths/total_cases))*100 as PercentDeath
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location
 --order by TotalDeathCount desc 


 
--View for Deathpercentage accross the globe
 create view DeathPercentage as
   select --date,
   sum(new_cases) as total_cases, sum(convert(int,new_deaths)) as TotalDeaths,
   sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 --group by date
-- order by 1,2

--View for percent population vaccinated
create view PercentPopulationVaccinated as
  select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths as dea
 join
 PortfolioProject..CovidVaccinations as vac
 on dea.location =vac.location
 and dea.date =vac.date
 where dea.continent is not null
 --order by 2,3
