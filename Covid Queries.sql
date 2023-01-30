Select *From CovidDeaths order by 3,4

Select *From CovidVaccinations order by 3,4

---Select data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population From CovidDeaths order by 1, 2

---Looking at Total Cases Vs Total Deaths 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 [Percentage of Deaths] From CovidDeaths order by 1, 2

--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 [Percentage of Deaths] From CovidDeaths 
where location like 'Cana%' and continent is not null
order by 1, 2

---Looking at Total Cases Vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 [Percentage of Population Infected] From CovidDeaths order by 1, 2

--Shows Percentage of Population who got covid in Canada
Select location, date, population, total_cases, (total_cases/population)*100 [Percentage of Population Infected] From CovidDeaths 
Where location like 'Cana%'
order by 1, 2

--Looking at countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) [Highest Infection Country], Max ((total_cases/population)*100) [[Percentage of Population Infected]
From CovidDeaths
Group by location, population
order by [Percentage of Population Infected] desc
---Showing Countries with Highest Death Count per Population 

Select location, population, Max(cast(total_deaths as int)) [Total Death Count] 
From CovidDeaths
where continent is not null
Group by location, population
order by  [Total Death Count] desc

--Let's break things down by Continent

--Showing the continents with highest death count per population 
Select continent, Max(cast(total_deaths as int))  [Total Death Count] 
From CovidDeaths
where continent is not null
Group by continent
order by [Total Death Count] desc

--GLOBAL NUMBERS


--Total new cases reported by date 
Select date, Sum (new_cases)[Total New Cases], Sum(Cast(new_deaths as int))[Total New Deaths], Sum(Cast(new_deaths as int))/sum(new_cases)*100 [Death Percentage]
From CovidDeaths
where continent is not null
group by Date
order by 1,2


--Showing total cases with deaths and death percentage

Select Sum (new_cases)[Total New Cases], Sum(Cast(new_deaths as int))[Total New Deaths], Sum(Cast(new_deaths as int))/sum(new_cases)*100 [Death Percentage]
From CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Population Vs Vaccinations

Select DEA.continent,DEA. location, DEA.date, DEA.population, VAC.new_vaccinations,
Sum (Cast (VAC.new_vaccinations as bigint)) Over (Partition by DEA. location) [Total New Vaccinations]
From CovidDeaths DEA join 
CovidVaccinations VAC
on DEA.location=VAC.location and DEA.date= VAC.date
where DEA.continent is not null
order by 1,2,3


Select DEA.continent,DEA. location, DEA.date, DEA.population, VAC.new_vaccinations,
Sum (Cast (VAC.new_vaccinations as bigint)) Over (Partition by DEA. location order by DEA. location, DEA.date) [Rolling People Vaccinated]
From CovidDeaths DEA join 
CovidVaccinations VAC
on DEA.location=VAC.location and DEA.date= VAC.date
where DEA.continent is not null
order by 3,4


--USE CTE

With PopVsVac ( Continent, Location, Date, Population,  New_Vaccinations, RollingPeopleVaccinated)

as
(
Select DEA.continent,DEA. location, DEA.date, DEA.population, VAC.new_vaccinations,
Sum ( Convert (bigint, VAC.new_vaccinations)) Over (Partition by DEA. location order by DEA. location, DEA.date) [Rolling People Vaccinated]
From CovidDeaths DEA join 
CovidVaccinations VAC
on DEA.location=VAC.location and DEA.date= VAC.date
where DEA.continent is not null
---order by 3,4
)

Select *, (RollingPeopleVaccinated/Population)*100 From PopVsVac


---Temp Table


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select DEA.continent,DEA. location, DEA.date, DEA.population, VAC.new_vaccinations,
Sum (Convert (bigint, VAC.new_vaccinations)) Over (Partition by DEA. location order by DEA. location, DEA.date) [Rolling People Vaccinated]
From CovidDeaths DEA join 
CovidVaccinations VAC
on DEA.location=VAC.location and DEA.date= VAC.date
where DEA.continent is not null
---order by 3,4


Select *, (RollingPeopleVaccinated/Population)*100 From #PercentPopulationVaccinated


----Creating view to store data for later Visualization

Create View PercentPopulationVaccinated as
Select DEA.continent,DEA. location, DEA.date, DEA.population, VAC.new_vaccinations,
Sum ( Convert (bigint, VAC.new_vaccinations)) Over (Partition by DEA. location order by DEA. location, DEA.date) [Rolling People Vaccinated]
From CovidDeaths DEA join 
CovidVaccinations VAC
on DEA.location=VAC.location and DEA.date= VAC.date
where DEA.continent is not null
---order by 3,4
