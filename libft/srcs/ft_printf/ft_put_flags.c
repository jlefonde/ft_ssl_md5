/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_put_flags.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jlefonde <marvin@42.fr>                    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/02/29 11:27:57 by jlefonde          #+#    #+#             */
/*   Updated: 2024/03/19 11:42:43 by jlefonde         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/libft.h"

/**
 * @brief Adds a space before positive numbers.
 *
 * @param args The variable argument list.
 * @param len The pointer to the length counter.
 * @param i The pointer to the index counter.
 */
void	ft_put_space(va_list args, int *len, int *i)
{
	int	n;

	n = va_arg(args, int);
	if (n >= 0)
		*len += ft_putstr(" ");
	*len += ft_putnbr(n, 1);
	*i = *i + 1;
}

/**
 * @brief Adds a plus before positive numbers.
 *
 * @param args The variable argument list.
 * @param len The pointer to the length counter.
 * @param i The pointer to the index counter.
 */
void	ft_put_plus(va_list args, int *len, int *i)
{
	int	n;

	n = va_arg(args, int);
	if (n >= 0)
		*len += ft_putstr("+");
	*len += ft_putnbr(n, 1);
	*i = *i + 1;
}

/**
 * @brief Adds the hexadecimal prefix.
 *
 * @param args The variable argument list.
 * @param len The pointer to the length counter.
 * @param i The pointer to the index counter.
 * @param c The character specifying the prefix ('x' or 'X').
 */
void	ft_put_sharp(va_list args, int *len, int *i, char c)
{
	unsigned int	n;

	n = (unsigned int)va_arg(args, int);
	if (n > 0)
	{
		if (c == 'x')
			*len += ft_putstr("0x");
		else if (c == 'X')
			*len += ft_putstr("0X");
	}
	*len += ft_puthex(n, (c == 'X'));
	*i = *i + 1;
}
