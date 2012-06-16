###
### Returns month name
###
month_name_rfunc<- function(x)
{
        month_name <- months(as.Date(paste("2000-",x,"-01",sep='')))
        month_name
}

monthNameFactory <- function()
{
        list(name=month_name_rfunc, udxtype=c("scalar"), intype=c("int"), outtype=c("varchar"))
}
