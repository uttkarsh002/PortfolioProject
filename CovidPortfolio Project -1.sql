Select *
From ProjectPortfolio..CovidDeaths
Where Continent is not null
Order by 3,4

Select *
From ProjectPortfolio..CovidVaccinations
Where Continent is not null
Order by 3,4

--Select Data that we are going to be using
--Shows Likelihood of dying if your contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage  
From ProjectPortfolio..CovidDeaths
--Where location like '%India%'
--and Continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows What Percentage of population got covid

Select Location, date, population , total_cases, (total_cases / population)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%India%'
and Continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

Select Location , Population , Max(total_cases) as HighestInfectionCount , Max(total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Where Continent is not null
Group by location , Population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count Per Population

Select Location , Max(Cast(total_deaths as int)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where Continent is not null
Group by location
Order by TotalDeathCount desc

--Let's Break Thing By Continent

--Showing Continents With The Highest Death Count Per Population

Select continent , Max(Cast(total_deaths as int)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Number

Select  new_cases as TotalCases, new_deaths as TotalDeaths, (CONVERT(float, new_deaths)) / NULLIF(CONVERT(float, new_cases), 0)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%India%'
Where Continent is not null
--Group by date , new_cases , new_deaths
order by 1,2


--Select Sum(new_cases) as Total_Cases , (Convert(Float,new_deaths)) as Total_Deaths ,(Convert(Float,new_deaths))/Sum(new_cases)*100 as DeathPercentage
--From ProjectPortfolio..CovidVaccinations
--Group by new_cases,new_deaths
--Order by 1,2


--Looking At Total Popultation vs Vaccinations

Select Dea.continent , Dea.location , Dea.date , Dea.population , Vac.new_vaccinations ,
Sum(Cast(vac.new_vaccinations as bigint)) Over ( Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths Dea
Join ProjectPortfolio..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
Order by 1,2

--Using CTE

With PopvsVac ( continent , location , date , population , new_vaccinations ,RollingPeopleVaccination)
as
(
Select Dea.continent , Dea.location , Dea.date , Dea.population , Vac.new_vaccinations ,
Sum(Cast(vac.new_vaccinations as bigint)) Over ( Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths Dea
Join ProjectPortfolio..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--Order by 1,2
)
Select *, (RollingPeopleVaccination/population)*100
From PopvsVac
 

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select Dea.continent , Dea.location , Dea.date , Dea.population , Vac.new_vaccinations ,
Sum(Cast(vac.new_vaccinations as bigint)) Over ( Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths Dea
Join ProjectPortfolio..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
--Where dea.continent is not null
--Order by 1,2
 
Select * , (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View To Store Data For Later Visualization

Create View PercentPopulationVaccinated as
Select Dea.continent , Dea.location , Dea.date , Dea.population , Vac.new_vaccinations ,
Sum(Cast(vac.new_vaccinations as bigint)) Over ( Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths Dea
Join ProjectPortfolio..CovidVaccinations Vac
On Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--Order by 1,2

Select*
From PercentPopulationVaccinated  



