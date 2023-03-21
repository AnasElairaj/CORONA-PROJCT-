----------------------------------------- CORONA PROJET DATA-BASE MADE BY ANAS ELAIRAJ ---------------------------------
--present our input 

--- cheking our Data : 

SELECT continent, location , COUNT (location) over (partition by  continent)  
from SQLPROJECT..CovidDeaths$
--where continent like '%Af%'
where continent is not null  
group by continent, location 
order by 1

-- Select data that we are going te be starting with : 

SELECT location, date, total_cases, new_cases, total_deaths , population 
from SQLPROJECT..CovidDeaths$
where continent is not null  
order by 1 

--  First Purpuse :  Total Cases vs Total Deaths 


--SELECT location, date, total_cases, new_cases, total_deaths , population, --case 
--when new_cases_smoothed = 0
--Then  null 
--Else (cast (new_cases as numeric )/cast(new_cases_smoothed as numeric))*100 
--end as Erreurpourcent 
--from SQLPROJECT..CovidDeaths$
--where continent is not null  


SELECT location, date, total_cases, new_cases, total_deaths , population , (cast (total_deaths as float)/cast (total_cases as float))*100 as Pourcentofdeath
from SQLPROJECT..CovidDeaths$
where continent is not null 
and location like '%mauritania'
--group by date
order by 2 desc 

-- for ex in Mauritania all first 149 cases are not insert in new_cases 

-- Total cases Vs Population :  

SELECT location, continent,  total_cases, new_cases, total_deaths , population , (cast (total_cases as float)/population)*100 as Rateofinfection 
from SQLPROJECT..CovidDeaths$
where continent is not null 
--and location like '%mauritania'
--group by location ,continent
--order by 2 desc 

-- Contries with Highest infection Rate compared to population  

Select Location, Population,  MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from SQLPROJECT..CovidDeaths$
where continent is not null 
-- and location like '%morocco' 
group by location , population
order by PercentPopulationInfected desc 

-- Contries with Highest death count compared to population  

Select Location, Population,date, Max (new_deaths) as HDEATH ,  MAX(total_deaths) as HighestDeath,  Max((total_deaths/population))*100 as PercentofDeath 
from SQLPROJECT..CovidDeaths$
where continent is not null 
and location like '%morocco' 
group by location , population, date 
order by HDEATH desc 

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from SQLPROJECT..CovidDeaths$
--Where location like '%Morocco%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from SQLPROJECT..CovidDeaths$
--Where location like '%Morocco%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine 


Select dea.continent, dea.location , dea.date, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from SQLPROJECT..CovidDeaths$ dea 
join SQLPROJECT..CovidVaccination$ vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.location is not null  
order by  2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location , dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from SQLPROJECT..CovidDeaths$ dea 
join SQLPROJECT..CovidVaccination$ vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.location is not null  
--order by  2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location , dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from SQLPROJECT..CovidDeaths$ dea 
join SQLPROJECT..CovidVaccination$ vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.location is not null  
--order by  2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location , dea.date, dea.population,  vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from SQLPROJECT..CovidDeaths$ dea 
join SQLPROJECT..CovidVaccination$ vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.location is not null  